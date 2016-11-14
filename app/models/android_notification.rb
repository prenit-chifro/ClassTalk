class AndroidNotification < ActiveRecord::Base
	validates :title, presence: true
	validates :message, presence: true
	validates :target_url, presence: true
end
