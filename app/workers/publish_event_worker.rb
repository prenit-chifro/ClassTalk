class PublishEventWorker
  include ApplicationHelper  
  include Sidekiq::Worker
  def perform(event_id)
    
    @event = Event.find_by(id: event_id)
    if(!@event.blank?)
        @notification = AndroidNotification.new 
        @notification.title = "#{@event.title} Event posted ! Click to open"
        @notification.message = @event.description
        @notification.target_url = "https://classtalk.in/institutes/#{@event.institute_id}/events"
        @notification.image_url = "https://classtalk.in" + @event.event_creator.profile_picture.media.url(:thumb)
        @notification.save

        @institute = Institute.find_by(id: @event.institute_id)
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