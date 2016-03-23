class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user

  def auth_callback
    current_user
    omniauth_origin = session[:omniauth_origin]
    session.delete(:onmiauth_origin)
    redirect_to omniauth_origin || '/'
  end

  def status
    head :ok, content_type: "text/html"
  end

  def redirect_protocol
    if request.ssl? || Rails.configuration.x.https_redirects
      'https://'
    else
      'http://'
    end
  end

  private

  def current_user
    if @current_user.nil?
      if session[:user_id]
        @current_user = User.find(session[:user_id])
      elsif omniauth_credentials
        credentials = omniauth_credentials
        @current_user = User.find_or_create_from_omniauth_hash(credentials)
      end

      if @current_user.nil?
        if Rails.application.config.force_authentication
          unless session[:omniauth_origin]
            session[:omniauth_origin] = request.original_url
            redirect_to('/auth/' + Rails.application.config.default_omniauth_provider.to_s)
          end
        end
      end

      session[:user_id] = @current_user.id if @current_user
    end

    @current_user || User.anonymous_user
  end

  def omniauth_credentials
    if omniauth_hash = request.env['omniauth.auth']
      {
          provider:   omniauth_hash['provider'],
          uid:        omniauth_hash['uid'],
          email:      omniauth_hash['info']['email'],
          name:       omniauth_hash['info']['name']
      }
    else
      nil
    end
  end
end
