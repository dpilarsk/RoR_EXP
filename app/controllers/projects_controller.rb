class ProjectsController < ApplicationController
	before_action :set_user, only: [:update]
	authorize_resource

	def insert
		columns = [:team_id, :name, :slug, :retries, :is_validated, :is_finished, :final_mark, :person_id, :cursus_id]
		@people = Person.all.order(:login)
		@people.each do |user|
			token = get_token
			projects_map = []
			user_infos = token.get("/v2/users/#{user['login']}").parsed
			if Project.exists?(person_id: user['id'])
				next
			end
			@projects = user_infos['projects_users']
			@projects.each do |project|
				if Project.exists?(team_id: project['current_team_id'], person_id: user['id'])
					next
				end
				projects_map << [project['current_team_id'], project['project']['name'], project['project']['slug'], project['occurrence'], project['validated?'], project['status'], project['final_mark'], user['id'], project['cursus_ids'][0]]
			end
			Project.import columns, projects_map
		end
		redirect_to(:controller => 'people', :action => 'index') and return
	end

	def update
		# if @user.nil?
		# 	columns = [:team_id, :name, :slug, :retries, :is_validated, :is_finished, :final_mark, :person_id, :cursus_id]
		# 	@users = Person.all.order(:login)
		# 	@users.each do |user|
		# 		token = get_token
		# 		projects_map = []
		# 		user_infos = token.get("/v2/users/#{user['login']}").parsed
		# 		@projects = user_infos['projects_users']
		# 		@projects.each do |project|
		# 			if !Project.exists?(team_id: project['current_team_id'], person_id: user['id'])
		# 				projects_map << [project['current_team_id'], project['project']['name'], project['project']['slug'], project['occurrence'], project['validated?'], project['status'], project['final_mark'], user['id'], project['cursus_ids'][0]]
		# 			else
		# 				Project.where(team_id: project['current_team_id'], person_id: user['id']).update_all(retries: project['occurrence'], is_validated: project['validated?'], final_mark: project['final_mark'], is_finished: project['status'])
		# 			end
		# 		end
		# 		Project.import columns, projects_map
		# 	end
		# else
			token = get_token
			user_infos = token.get("/v2/users/#{@person.login}").parsed
			@projects = user_infos['projects_users']
			@projects.each do |project|
				if !Project.exists?(team_id: project['current_team_id'], person_id: @person.id)
					@new_project = Project.new(:team_id => project['current_team_id'], :name => project['project']['name'], :slug => project['project']['slug'], :retries => project['occurrence'], :is_validated => project['validated?'], :is_finished => project['status'], :final_mark => project['final_mark'], :person_id => user['id'], :cursus_id => project['cursus_ids'][0])
					@new_project.save
				else
					Project.where(team_id: project['current_team_id'], person_id: @person.id).update_all(retries: project['occurrence'], is_validated: project['validated?'], final_mark: project['final_mark'], is_finished: project['status'])
				end
			end
		# end
		redirect_to(:controller => 'people', :action => 'show') and return
	end

	private

	def set_user
		if params.has_key?(:id)
			if Person.exists?(login: params[:id])
				@person = Person.find_by_login(params[:id])
			else
				@person = nil
			end
		end
	end

	def get_token
		api_client = OAuth2::Client.new('', '', site: "https://api.intra.42.fr")
		token = api_client.client_credentials.get_token
		return token
	end
end
