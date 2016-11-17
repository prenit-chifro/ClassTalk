class MyDevise::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  $current_user_id = nil
  
  def facebook
    if request.env["omniauth.auth"].info.email.blank?
      redirect_to "/users/auth/facebook?auth_type=rerequest&scope=email"
    end
  
        @user = User.from_omniauth(request.env["omniauth.auth"])
    
    # check if user had signed in previously and is already saved in database or it is first time sign in
    if @user.persisted?
      handle_omniauth_sign_in(@user, "Facebook")
    else
      handle_omniauth_sign_up(@user, "Facebook")
    end
    end
  
  # You need to implement the method below in your model (e.g. app/models/user.rb)
  def google_oauth2
    
    @user = User.from_omniauth(request.env["omniauth.auth"])

    # check if user had signed in previously and is already saved in database or it is first time sign in
    if @user.just_signed_up == false
      handle_omniauth_sign_in(@user, "Google")
    else
      handle_omniauth_sign_up(@user, "Google")
    end
  end

  def failure
    redirect_to root_path
  end 
  
  private 
  def handle_omniauth_sign_in user, provider
    
    sign_in(user)
    user.remember_me!

    if(user.email_verified == false)
      user.email_verified = true
      user.save
    end
    
    set_current_user_id(user.id)
    
    if(check_whether_requested_from_android_webview)
      set_send_gcm_registration_id_to_backend_flag(true)
    end
    
    flash[:notice] = "Welcome #{'' + user.email if user.first_name.blank?}#{user.first_name}. Successfully Signed In with #{provider} Account"
    redirect_to root_path, :event => :authentication
  end
  
  private
  def handle_omniauth_sign_up user, provider
    user_password = Random.new.rand(1000..9999).to_s
    
    user.password = user_password
    if(check_whether_requested_from_android_webview)
      user.send_account_password_on_android_device_flag = true
      set_send_gcm_registration_id_to_backend_flag(true)
    end
    
    user.save
    
    sign_in(user)
    user.remember_me!

    save_user_password_with_system_encryption_key(user, user_password)  
    send_user_account_password_through_email(user, user_password)
    
    set_current_user_id(user.id)
    
    flash[:notice] = "Welcome #{'' + user.email if user.first_name.blank?}#{user.first_name}. Successfully Signed Up with #{provider} Account"
    redirect_to complete_registration_user_path(user), :event => :authentication
  end
    
  private
  def set_current_user_id id
    $current_user_id = id.to_s
  end
  
  after_filter :send_current_user_id_in_header_flag_and_value

  private
  def send_current_user_id_in_header_flag_and_value
    set_send_current_user_id_in_header_flag(true, $current_user_id)
  end   
end
