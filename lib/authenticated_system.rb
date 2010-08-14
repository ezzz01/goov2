module AuthenticatedSystem
  protected
    # Accesses the current user from the session.
    # Future calls avoid the database because nil is not equal to false.
    def current_user
        @current_user ||= (login_from_session || login_from_cookie || login_from_fb) unless @current_user == false
    end

    # Store the given user id in the session.
    def current_user=(new_user)
      session[:user_id] = new_user ? new_user.id : nil
      @current_user = new_user || false
    end

    #
    # Login
    #

    # Called from #current_user.  First attempt to login by the user id stored in the session.
    def login_from_session
      self.current_user = User.find_by_id(session[:user_id]) if session[:user_id]
    end

    # Called from #current_user.  Finaly, attempt to login by an expiring token in the cookie.
    # for the paranoid: we _should_ be storing user_token = hash(cookie_token, request IP)
    def login_from_cookie
      user = cookies[:auth_token] && User.find_by_persistence_token(cookies[:auth_token])
      puts cookies.inspect
      if user && user.remember_token?
        self.current_user = user
        handle_remember_cookie! false # freshen cookie token (keeping date)
        self.current_user
      end
    end

    def login_from_fb
      if facebook_session
        begin
          self.current_user = User.find_by_fb_user(facebook_session.user)
        rescue 
          self.current_user = false
        end
      end
    end


    # Inclusion hook to make #current_user and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_user if base.respond_to? :helper_method
    end

    
    #
    # Remember_me Tokens
    #
    # Cookies shouldn't be allowed to persist past their freshness date,
    # and they should be changed at each login
    def valid_remember_cookie?
      return nil unless @current_user
      (@current_user.remember_token?) && 
        (cookies[:auth_token] == @current_user.remember_token)
    end
    
    # Refresh the cookie auth token if it exists, create it otherwise
    def handle_remember_cookie!(new_cookie_flag)
      return unless @current_user
      case
      when valid_remember_cookie? then @current_user.refresh_token # keeping same expiry date
      when new_cookie_flag        then @current_user.remember_me 
      else                             @current_user.forget_me
      end
      send_remember_cookie!
    end
  
    def kill_remember_cookie!
      cookies.delete :auth_token
    end
    
    def send_remember_cookie!
      cookies[:auth_token] = {
        :value   => @current_user.remember_token,
        :expires => @current_user.remember_token_expires_at }
    end

end
