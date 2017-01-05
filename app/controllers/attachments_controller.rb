class AttachmentsController < ApplicationController

	before_action :set_attachment

	def set_attachment
		@attachment = Attachment.find_by(id: params[:id])
	end

	def download
		if(!@attachment.blank?)
			send_file Rails.root + @attachment.media.path
		end
	end
end
