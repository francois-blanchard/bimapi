class PagesController < ApplicationController
	def home
		render :json => { :status => :ok, :message => "Success!", :html => "Bim API" }
	end
end
