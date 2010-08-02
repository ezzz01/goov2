# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ApplicationHelper
  include AuthenticatedSystem

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  before_filter :set_facebook_session
  helper_method :facebook_session

  rescue_from  Facebooker::Session::SessionExpired do
    clear_facebook_session_information
    clear_fb_cookies!    
    reset_session
    redirect_to root_url
  end

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

  rescue_from CanCan::AccessDenied do |exception|
      flash[:error] = t(:no_permission)
      redirect_to root_url
  end

  def verify_authenticity_token
    super unless request_comes_from_facebook?
  end

end
