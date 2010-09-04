class UserSessionsController < ApplicationController
  def new
    @title = t(:login)
    @user_session = UserSession.new
    session[:logout] = nil 
  end

  def create
    @user_session = UserSession.new(params[:user_session])
      if @user_session.save
        flash[:notice] = t(:login_successful) 
        redirect_to root_url
      else
        render :action => "new" 
      end
  end

  def destroy
    session[:logout] = true 
    session[:user_id] = nil
    session[:facebook_session] = nil
    session[:session_id] = nil
    facebook_session = nil
    @current_user = false 
    flash[:notice] = t(:logout_successful) 
    redirect_to root_url 
  end

end
