class Attachment < ApplicationRecord
	
	belongs_to :attachable, polymorphic: true
	
	has_attached_file :media, 	styles: lambda { |attachment| attachment.instance.get_style_for_attachment(attachment.instance)},
								:default_url => lambda { |attachment| attachment.instance.get_default_url_for_attachment(attachment.instance)},
								:url  => ":get_url_for_attachment/:basename.:extension",
								:path => ":rails_root/:get_path_for_attachment/:basename.:extension"
								
	validates_attachment_content_type :media, :content_type => [/\Aimage\/.*\Z/, /\Avideo\/.*\Z/, /\Aaudio\/.*\Z/, /\Aapplication\/.*\Z/ ]
	
	def file_path
		if self.is_image_type?
			"public/attachments/original/#{self.attachable_type}/#{self.attachable_id}"
		elsif self.is_video_type?
			"public/attachments/original/#{self.attachable_type}/#{self.attachable_id}"
		else
			"public/attachments/#{self.attachable_type}/#{self.attachable_id}"
		end
	end

	def save_attachment_media_from_url media_url
		self.media = open(media_url)
		content_type = self.media_content_type.split("/").last
		if(!self.media_file_name.include?(".#{content_type}"))
			new_file_name = self.media_file_name + ".#{content_type}"
			self.media_file_name = new_file_name
		end
	end
	
	def get_style_for_attachment(attachment_model)
		if is_image_type?
		  {:thumb => "100x100#", :medium => "500x500>", :large => "1000x1000>"}
		elsif is_video_type?
		  {
			  :thumb => { :geometry => "100x100#", :format => 'jpg', :time => 10, :processors => [:transcoder] },
			  :medium => {:geometry => "250x250#", :format => 'mp4', :time => 10, :processors => [:transcoder] },
			  :large => {:geometry => "500x500#", :format => 'mp4', :time => 10, :processors => [:transcoder] }
		  }
		else
		  {}
		end
	end
	
	def get_default_url_for_attachment(attachment_model_instance)
		if(attachment_model_instance.attachable_type == "User")
			return "/attachments/default_profile_picture.png"
		end
		
		if(attachment_model_instance.attachable_type == "Conversation")
			return "/attachments/default_profile_picture.png"
		end
				
		if is_image_type?
			"/attachments/default_attached_image.png"
		elsif is_video_type?
			"/attachments/default_attached_video.mp4"
		elsif is_audio_type?
			"/attachments/default_attached_audio.mp3"
		else
		  ""
		end
		
	end
		
	def is_image_type?
		media_content_type =~ %r(image)
	end

	def is_video_type?
		media_content_type =~ %r(video)
	end
	
	def is_audio_type?
		media_content_type =~ %r(audio)
	end
	
	def is_document_type?
		media_content_type =~ %r(application)
	end
	
	Paperclip.interpolates :get_url_for_attachment do |media, style|
		if media.instance.is_image_type?
			"/attachments/#{style}/#{media.instance.attachable_type}/#{media.instance.attachable_id}"
		elsif media.instance.is_video_type?
			"/attachments/#{style}/#{media.instance.attachable_type}/#{media.instance.attachable_id}"
		else
			"/attachments/#{media.instance.attachable_type}/#{media.instance.attachable_id}"
		end
	end
	
	Paperclip.interpolates :get_path_for_attachment do |media, style|
		if media.instance.is_image_type?
			"public/attachments/#{style}/#{media.instance.attachable_type}/#{media.instance.attachable_id}"
		elsif media.instance.is_video_type?
			"public/attachments/#{style}/#{media.instance.attachable_type}/#{media.instance.attachable_id}"
		else
			"public/attachments/#{media.instance.attachable_type}/#{media.instance.attachable_id}"
		end
	end
end
