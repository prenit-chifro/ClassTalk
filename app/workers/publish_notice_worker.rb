class PublishNoticeWorker
  include ApplicationHelper  
  include Sidekiq::Worker
  def perform(notice_id)
    
    @notice = Notice.find_by(id: notice_id)
    if(!@notice.blank?)
        @notification = AndroidNotification.new 
        @notification.title = "New notice posted ! Click to open"
        @notification.message = @notice.title
        @notification.target_url = "https://classtalk.in/institutes/#{@notice.institute_id}/notices"
        @notification.image_url = "https://classtalk.in" + @notice.notice_creator.profile_picture.media.url(:thumb)
        @notification.save

        @institute = Institute.find_by(id: @notice.institute_id)
        @institute_members = @institute.members
        participants_android_devices = []
        @institute_members.each do |member|
            participant_android_devices = member.android_devices
            if(!participant_android_devices.blank?)
                participant_android_devices.each do |d|
                    participants_android_devices << d
                end
            end
            
                
                
            android_device_ids = participants_android_devices.map{|d| d.gcm_registration_id}
            send_gcm_notification(@notification, android_device_ids)

            ios_devices = member.ios_devices.where(is_ios_device_user_signed_in: true)
            if(!ios_devices.blank?)
                send_ios_notification(@notification, ios_devices.map(&:ios_device_token))
            end
            
            web_notification = {title: @notification.title, body: @notification.message, icon: @notification.image_url, target_url: @notification.target_url}
            publish_web_notification(member, web_notification)
            
        end 
    end
  end
end