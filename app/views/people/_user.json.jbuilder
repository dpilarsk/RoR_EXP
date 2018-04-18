json.extract! user, :id, :login, :uid
json.url user_url(user, format: :json)
