class PeopleController < ApplicationController
	before_action :set_user, only: [:show, :edit, :update, :destroy]
	authorize_resource
	helper_method :sort_column, :sort_direction

	# GET /people
	# GET /people.json
	def index
		if params.has_key?(:search)
			@people = Person.where("login LIKE ?", "%#{params[:search]}%").page params[:page]
			if @people.count == 1
				redirect_to(:action => 'show', id: params[:search]) and return
			elsif @people.count == 0
				redirect_to(:action => 'index') and return
			end
			render 'search'
		elsif (params.has_key?(:login))
			redirect_to(:action => 'show', id: params[:login]) and return
		end
		if params.has_key?(:sort)
			cookies[:sort] = sort_column
			cookies[:direction] = sort_direction
		end
		if params.has_key?(:year) && params.has_key?(:month)
			@people = Person.all.where({pool_year: params[:year], pool_month: params[:month]}).order(sort_column + " " + sort_direction).page params[:page]
		else
			@people = Person.all.order(cookies[:sort].to_s + " " + cookies[:direction].to_s).page params[:page]
		end
		if params.has_key?(:page)
			cookies[:page] = params[:page]
		else
			cookies[:page] = 1
		end
	end

	# GET /people/1
	# GET /people/1.json
	def show
	end

	def update_admitted
		@people = Person.all.order(:login)
		@people.each do |person|
			token = get_token
			Person.where(login: person.login, id: person.id).update_all(is_admitted: is_admitted?(token, person))
			sleep(2)
		end
		flash[:notice] = 'Update admission done'
		redirect_to(:action => 'index') and return
	end

	def get_pool
		columns = [:uid, :login, :first_name, :last_name, :pool_year, :pool_month, :level, :is_admitted, :image_url]
		10.times do |time|
			users_map = []
			token = get_token
			users = token.get('/v2/campus/paris/users', params: {sort: 'login', filter: {pool_year: params[:pool_year].to_i, pool_month: "#{params[:pool_month]}"}, page: {number: time + 1, size: 100}}).parsed
			users.each do |user|
				user_infos = token.get("/v2/users/#{user['login']}").parsed
				if Person.exists?(uid: user_infos['id'])
					next
				end
				path = Rails.root.join('public', 'uploads', user_infos['pool_year'] +  "/" + user_infos['pool_month'] + "/" + user_infos['login'] + ".jpg")
				path2 = "/uploads/#{params[:pool_year]}/#{params[:pool_month]}/#{user_infos['login']}.jpg"
				# @nuser = Person.new(:uid => user_infos['id'], :login => user_infos['login'], :first_name => user_infos['first_name'], :last_name => user_infos['last_name'], :pool_year => params[:pool_year].to_i, :pool_month => params[:pool_month], :level => get_level(user_infos), :is_admitted => is_admitted?(token, user_infos), :image_url => path2)
				# @nuser.save
				FileUtils.mkdir_p(Rails.root.join('public', 'uploads', user_infos['pool_year'] +  "/" + user_infos['pool_month'] + "/")) unless File.directory?(Rails.root.join('public', 'uploads', user_infos['pool_year'] +  "/" + user_infos['pool_month'] + "/"))
				users_map << [user_infos['id'], user_infos['login'], user_infos['first_name'], user_infos['last_name'], params[:pool_year].to_i, params[:pool_month], get_level(user_infos), is_admitted?(token, user_infos), path2]
				user_infos['image_url'] = 'https://cdn.intra.42.fr/users/medium_default.png' if user_infos['image_url'].eql? 'https://cdn.intra.42.fr/images/default.png'
				Thread.new do
					image = MiniMagick::Image.open("#{user_infos['image_url']}")
					image.write(path)
				end
			end
			Person.import columns, users_map, :validate => true
		end
		redirect_to(:action => 'index') and return
	end

	# GET /people/1/edit
	def edit
	end

	# PATCH/PUT /people/1
	# PATCH/PUT /people/1.json
	def update
		token = get_token
		user_infos = token.get("/v2/users/#{@person.login}").parsed
		Person.where(login: @person.login, id: @person.id).update_all(level: get_level(user_infos), is_admitted: is_admitted?(token, user_infos))
		flash[:notice] = 'Person updated'
		redirect_to(:action => 'show', params[:id] => @person.login) and return
	end

	private
	# Use callbacks to share common setup or constraints between actions.
	def set_user
		if Person.exists?(login: params[:id])
			@person = Person.find_by_login(params[:id])
		else
			redirect_to :action => 'index'
		end
	end

	def sort_column
		Person.column_names.include?(params[:sort]) ? params[:sort] : "level"
	end

	def sort_direction
		%w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
	end

	def get_level(user_infos)
		level = 0
		4.times do |time|
			unless user_infos['cursus_users'][time].nil?
				if user_infos['cursus_users'][time]['cursus']['name'].eql? 'Piscine C décloisonnée'
					level = user_infos['cursus_users'][time]['level']
					break
				else
					level = 0
					next
				end
			end
		end
		return level
	end

	def get_token
		api_client = OAuth2::Client.new('', '', site: "https://api.intra.42.fr")
		token = api_client.client_credentials.get_token
		return token
	end

	def is_admitted?(token, user)
		admit = 0
		tiges = token.get("/v2/users/#{user['login']}/closes").parsed
		return admit = 2 if tiges.empty?
		tiges.each do |tig|
			unless (tig['reason'].eql? 'Non admitted') || (tig['reason'].eql? "Piscine d'aout 2016 non validée")
				admit = 1
				break
			else
				admit = 0
				break
			end
		end
		return admit
	end

	# Never trust parameters from the scary internet, only allow the white list through.
	def user_params
	  params.fetch(:user, {})
	end
end
