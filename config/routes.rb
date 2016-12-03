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
        
        get "add_new_student"
        post "add_new_student"

        get "add_new_parent"
        post "add_new_parent"

        get "add_new_teacher"
        post "add_new_teacher"

        get "add_new_staff"
        post "add_new_staff"
  		end

      resources :events

      resources :timetable_slots

      resources :notices

      resources :attendance_records

      resources :grades do
        collection do
          get "add_new_grade"
          post "add_new_grade"
        end
        resources :sections do
          collection do
            get "add_new_section"
            post "add_new_section"
          end
          resources :subjects do
             collection do
              get "add_new_subject"
              post "add_new_subject"
            end 
          end

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
        get "homework"
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
   	
end
