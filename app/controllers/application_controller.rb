# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ApplicationHelper

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :fb_sig_friends, :password, :password_confirmation

  before_filter :set_facebook_session
  helper_method :facebook_session, :current_user, :facebook_user

  before_filter :current_user

 
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

  def current_user
    @current_user ||= (login_from_session || login_from_fb) unless @current_user == false
  end

  protected

  # Called from #current_user.  First attempt to login by the user id stored in the session.
  def login_from_session
    puts "tadas: try login from session"
    self.current_user = User.find_by_id(session[:user_id]) if session[:user_id]
  end

  def login_from_fb
    puts "session: " + session[:logout].inspect
    puts "tadas: try login from facebook"
    if facebook_session && session[:logout] != true
      self.current_user = User.find_by_fb_user(facebook_session.user)
    end
  end

  # Store the given user id in the session.
  def current_user=(new_user)
    session[:user_id] = new_user ? new_user.id : nil
    @current_user = new_user || false
  end




end
