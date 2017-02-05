class HomeController < ApplicationController

	def index
		
	end
	
	def help
	
	end

	def download_institute_data_template
		send_file File.join(Rails.root, "public", "institute_data_template.xls")
	end

end
