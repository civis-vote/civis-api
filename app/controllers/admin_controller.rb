class AdminController < ApplicationController
	layout 'admin_panel_sidenav'
	before_action :authenticate_user!
	before_action :require_admin
	def dashboard

	end
	
end
