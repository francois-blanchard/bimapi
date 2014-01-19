# update token when auth

# normaliser les messages de retour json (error => true/false, message => , token => )
# Retour de l'api
# {
# 	status => "success|error"
#	data => {
#		"post" => { id => 1, ... }
# 	}
# 	message => "..."
# }

module MyErrorFormatter
  def self.call message, backtrace, options, env
      { :status => 'error', :message => message }.to_json
  end
end

module Bim
  class UserApi < Grape::API
  	version 'v1'
	format :json

	error_formatter :json, MyErrorFormatter
	
	helpers do
		def authenticate!
			error!('Unauthorized token', 401) unless current_user
		end
	 
		def current_user
		  # find token. Check if valid.
		  key = ApiKey.where(:access_token => params[:token]).first
		  if key && !key.expired?
			@current_user = User.find(key.user_id)
		  else
			false
		  end
		end
	end
		
	# /api/:vesrion/auth
	resource :auth do
		# ---------------------------------------------------------
		desc "Creates user with params send and return"
		params do
		  requires :email, :type => String, :desc => "Email address"
		  requires :password, :type => String, :desc => "Password"
		  requires :pseudo, :type => String, :desc => "Pseudo"
		end
		post :signin do
			@user = User.new(:email => params[:email], :password => params[:password], :password_confirmation => params[:password], :pseudo => params[:pseudo])

			if @user.save
				key = ApiKey.create(:user_id => @user.id)
				{ :status => "success", :data => {:token => key.access_token}, :message => "User was created" }
			else
				{ :status => "error", :message => @user.errors }
			end
		end
		# ---------------------------------------------------------
		desc "Creates and returns access_token if valid login"
		params do
		  requires :login, :type => String, :desc => "Email or Pseudo"
		  requires :password, :type => String, :desc => "Password"
		end
		post :login do

			user = User.find_for_authentication(:login => params[:login])
		 	
		 	if user && user.valid_password?(params[:password])
				key = ApiKey.where(:user_id => user.id).first
				key.save
				{:status => "success", :data => {:token => key.access_token}, :message => "Auth success"}
		 	else
				error!('Unauthorized token.', 401)
		  	end
		end
		# ---------------------------------------------------------
		desc "Returns pong if logged in correctly"
		params do
		  requires :token, :type => String, :desc => "Access token."
		end
		get :ping do
		  authenticate!
		  { :status => "success", :message => "pong" }
		end
	end

  end
end