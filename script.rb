require "oauth2"
require "mysql2"

def insert_users(token, client)
	10.times do |time|
		users = token.get('/v2/campus/paris/users', params: {sort: 'login', filter: {pool_year: 2017, pool_month: 'july'}, page: {number: time + 1, size: 100}}).parsed
		users.each do |user|
			user_infos = token.get("/v2/users/#{user['login']}").parsed
			unless user_infos["cursus_users"][0].nil?
				level = user_infos["cursus_users"][0]["level"]
			else
				level = 0
			end
			insert = client.prepare("REPLACE INTO users (uid, login, first_name, last_name, pool_year, pool_month, level) VALUES (?, ?, ?, ?, ?, ?, ?)")
			insert.execute(user_infos['id'], user_infos['login'], user_infos['first_name'], user_infos['last_name'], user_infos['pool_year'], user_infos['pool_month'], level)
			insert.close
			puts user['login']
		end
	end
	puts "Finish!"
end

def get_users(token, client)
	40.times do |time|
		users = token.get('/v2/campus/paris/users', params: {sort: 'login', filter: {pool_year: 2015}, page: {number: time + 11, size: 100}}).parsed
		users.each do |user|
			user_infos = token.get("/v2/users/#{user['login']}").parsed
			unless user_infos["cursus_users"][1].nil?
				level = user_infos["cursus_users"][1]["level"]
			else
				level = 0
			end
			#insert = client.prepare("REPLACE INTO 2015_users_42 (level, login) VALUES (?, ?)")
			#insert.execute(level, user_infos['login'])
			#insert.close
			puts user['login']
		end
	end
	puts "Finish!"
end

def check_nil(user_infos, client)
	if user_infos['cursus_users'][0].nil?
		level = 0
	else
		if user_infos['cursus_users'][0]['grade'].nil?
			level = user_infos['cursus_users'][0]['level']
		else
			if user_infos['cursus_users'][1].nil?
				level = 0
			else
				if user_infos['cursus_users'][1]['grade'].nil?
					level = user_infos['cursus_users'][1]['level']
				else
					if user_infos['cursus_users'][2].nil?
						level = 0
					else
						if user_infos['cursus_users'][2]['grade'].nil?
							level = user_infos['cursus_users'][2]['level']
						else
							level = 0
						end
					end
				end
			end
		end
	end
	puts "UPDATE #{user_infos['login']}"
	client.query "UPDATE users SET level = #{level} WHERE login = '#{user_infos['login']}'"
end

def update_users(token, client)
	users = client.query("SELECT * FROM users WHERE pool_month = 'july' ORDER BY login ASC")
	users.each do |user|
		# user_infos = token.get("/v2/users/#{user['login']}").parsed
		# unless user_infos["cursus_users"][1].nil?
		# 	level = user_infos["cursus_users"][1]["level"]
		# else
		# 	level = 0
		# end
		# insert = client.prepare("REPLACE INTO 2015_users_42 (level, login) VALUES (?, ?)")
		# insert.execute(level, user_infos['login'])
		# insert.close
		# puts user['login']
		user_infos = token.get("/v2/users/#{user['login']}").parsed
		check_nil(user_infos, client)
	end
	puts "Finish!"
end

begin
	client = Mysql2::Client.new(:host => '', :port => '', :username => '', :password => '', :database => '')
	UID = ''
	SECRET = ''
	puts UID
	api_client = OAuth2::Client.new(UID, SECRET, site: "https://api.intra.42.fr")
	token = api_client.client_credentials.get_token
	puts token
	# insert_users(token, client)
	 get_users(token, client)
	#update_users(token, client)
ensure
	client.close
end
