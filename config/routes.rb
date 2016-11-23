Rails.application.routes.draw do
  
  	# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  	root to: "conversations#index"
  
  	devise_for :users, controllers: { sessions: 'my_devise/sessions', registrations: 'my_devise/registrations', omniauth_callbacks: 'my_devise/omniauth_callbacks', passwords: 'my_devise/passwords', unlocks: 'my_devise/unlocks' }
    
  	resources :users do
  		member do 
  			get :complete_registration 
  			post :complete_registration 
  		end	
  	end
  	
  	resources :institutes do
  		member do
  			get "add_new_member"
  			post "add_new_member"
  		end

      resources :events

      resources :timetable_slots

      resources :notices

      resources :attendance_records

      resources :grades do
        resources :sections do
          resources :subjects
        end
      end
  	end

    resources :conversations do
      resources :messages do
        member do
          post "set_seen_user_id"
          get "seen_by_users"

          post "set_acted_user_ids"
          get "acted_by_users"
        end
      end
      member do
        post "add_message_category"
        delete "delete_message_category"
      end

      collection do
        get "new_group"
        post "new_group"
        get "my_classwork"
      end  
    end

  	resources :android_devices
    resources :ios_devices
    resources :web_notification_subscriptions
    resources :apple_web_notification_subscriptions

    scope format: false, constraints: {website_push_id: /[a-zA-Z0-9\._-]+/} do
    	post '/:version/pushPackages/:website_push_id' => 'safari_web_push#send_push_package'
	    post '/:version/devices/:device_token/registrations/:website_push_id' => 'safari_web_push#register_device'
	    delete '/:version/devices/:device_token/registrations/:website_push_id' => 'safari_web_push#unregister_device'
	    post '/:version/log' => 'safari_web_push#log'
	  end

    mount ActionCable.server => '/cable'
    
    get "another_route" => "home#another_route"
    
    get "messages_route" => "home#messages_route"
    
    get "subject_route" => "home#subject_route"
    
    get "self_route" => "home#self_route"
    
    get "another_profile_route" => "home#another_profile_route"
    
    get "institute_information_route" => "home#institute_information_route"
    
    get "teacher_notice_route" => "home#teacher_notice_route"
    
    get "teacher_attendance_route" => "home#teacher_attendance_route"

  
    
    get "admin_main_route" => "home#admin_main_route"
    
    get "admin_class_page_route" => "home#admin_class_page_route"
    
    
    
    get "parent_index" => "home#parent_index"
    
    get "parent_another_route" => "home#parent_another_route"
    
    get "parent_subject_route" => "home#parent_subject_route"
    
    get "parent_self_route" => "home#parent_self_route"
    
    get "parent_another_profile_route" => "home#parent_another_profile_route"
    
    get "parent_institute_information_route" => "home#parent_institute_information_route"
    
    get "parent_notice_route" => "home#parent_notice_route"
    
    get "parent_attendance_route" => "home#parent_attendance_route"
  	
end
