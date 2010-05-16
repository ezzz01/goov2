# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  helper_method :current_user

  def param_posted? (symbol)
    request.post? and params[symbol]
  end

  def redirect_to_forwarding_url
    if (redirect_url = session[:protected_page])
      session[:protected_page] = nil
      redirect_to redirect_url
    else
      redirect_to :action => "index"
    end
  end

  def try_to_update(user, attribute)
    if user.update_attributes(params[:user])
      flash[:notice] = "#{attribute} "+t(:attribute_updated)
      redirect_to :action => "index"
    end
  end

  private

  def current_user_session   
    return @current_user_session if defined?(@current_user_session)   
    @current_user_session = UserSession.find   
  end   
  
  def current_user   
    @current_user = current_user_session && current_user_session.record   
  end   


end
