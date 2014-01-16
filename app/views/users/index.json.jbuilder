json.array!(@users) do |user|
  json.extract! user, :id, :email, :pseudo
  json.url user_url(user, format: :json)
end
