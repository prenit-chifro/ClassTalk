class PublishAttendanceWorker
  include ApplicationHelper  
  include Sidekiq::Worker
  def perform(attendance_record_id)
    
    @attendance_record = AttendanceRecord.find_by(id: attendance_record_id)
    if(!@attendance_record.blank?)
        @notification = AndroidNotification.new 
        @notification.title = "You were absent on #{get_month_date_year(@attendance_record.date)} !"
        @notification.message = "Class #{@attendance_record.grade.custom_name_for_institute(@attendance_record.institute)} #{@attendance_record.section.section_name}, #{get_month_date_year(@attendance_record.date)}"
        @notification.target_url = "https://classtalk.in/institutes/#{@attendance_record.institute_id}/attendance_records"
        @notification.image_url = "https://classtalk.in" + @attendance_record.record_creator.profile_picture.media.url(:thumb)
        @notification.save

        @absent_students = @attendance_record.absent_students

        @institute = @attendance_record.institute
        
        participants_android_devices = []
        @absent_students.each do |member|
            participant_android_devices = member.android_devices
                
            android_device_ids = participant_android_devices.map{|d| d.gcm_registration_id}
            send_gcm_notification(@notification, android_device_ids)

            ios_devices = member.ios_devices.where(is_ios_device_user_signed_in: true)
            if(!ios_devices.blank?)
                send_ios_notification(@notification, ios_devices.map(&:ios_device_token))
            end
            
            web_notification = {title: @notification.title, body: @notification.message, icon: @notification.image_url, target_url: @notification.target_url}
            publish_web_notification(member, web_notification)
        end

        @notification.title = "Your Child was absent on #{get_month_date_year(@attendance_record.date)} !"
        @absent_students.each do |member|
            father = member.father
            if(!father.blank?)

                participant_android_devices = father.android_devices
                    
                android_device_ids = participant_android_devices.map{|d| d.gcm_registration_id}
                send_gcm_notification(@notification, android_device_ids)

                ios_devices = father.ios_devices.where(is_ios_device_user_signed_in: true)
                if(!ios_devices.blank?)
                    send_ios_notification(@notification, ios_devices.map(&:ios_device_token))
                end
                
                web_notification = {title: @notification.title, body: @notification.message, icon: @notification.image_url, target_url: @notification.target_url}
                publish_web_notification(father, web_notification)
            end

            mother = member.mother
            if(!mother.blank?)

                participant_android_devices = mother.android_devices
                    
                android_device_ids = participant_android_devices.map{|d| d.gcm_registration_id}
                send_gcm_notification(@notification, android_device_ids)

                ios_devices = member.ios_devices.where(is_ios_device_user_signed_in: true)
                if(!ios_devices.blank?)
                    send_ios_notification(@notification, ios_devices.map(&:ios_device_token))
                end
                
                web_notification = {title: @notification.title, body: @notification.message, icon: @notification.image_url, target_url: @notification.target_url}
                publish_web_notification(mother, web_notification)
            end 
        end    
    end
  end
end