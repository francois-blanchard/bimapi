require 'bim/user_api'

class API < Grape::API
  mount Bim::UserApi
end