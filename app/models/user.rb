class User < ActiveRecord::Base
	attr_accessor :login
  	devise :database_authenticatable, :registerable,
		 :recoverable, :rememberable, :trackable, :validatable, :authentication_keys => [:login]

	has_many :api_keys
	validates :pseudo,
	  :uniqueness => {
	    :case_sensitive => false
	  }

	def login=(login)
	  @login = login
	end

	def login
	  unless @login
	    if self.pseudo
	      self.pseudo
	    else
	      self.email
	    end
	  else
	    @login
	  end
	end

	def self.find_first_by_auth_conditions(warden_conditions)
      conditions = warden_conditions.dup
      if login = conditions.delete(:login)
        where(conditions).where(["lower(pseudo) = :value OR lower(email) = :value", { :value => login.downcase }]).first
      else
        where(conditions).first
      end
    end

    def self.authenticate(login, password)
		user = User.find_for_authentication(:login => login)
		user.valid_password?(password) ? user : nil
	end

end
