class UsersController < ApplicationController
  load_and_authorize_resource

  # GET /users
  # GET /users.xml
  def index
    @users = User.paginate(:page => params[:page], :per_page => 10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    find_user(params)
    if @user
      @title = t(:user_profile, :username => @user.username)
     # @posts = @user.posts
     # @activities = @user.activities
      respond_to do |format|
        format.html 
      end
    else 
      flash[:notice] = t(:no_such_user)
      redirect_to users_path
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  def create
    respond_to do |format|
        @user = User.new(params[:user])
        if @user.save
          flash[:notice] = t(:registration_successful) 
          session[:user_id] = @user.id
          format.html { redirect_to user_profile_path(@user.try(:username)) }
        else 
          @user.clear_password!
          format.html { render :action => "new" }
        end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
  #  @user = @current_user # makes our views "cleaner" and more consistent
    @avatar = Avatar.new(:uploaded_data => params[:avatar_file])

    respond_to do |format|
      #if we have an uploaded avatar
      if params[:avatar_file]
        @service = UserService.new(@user, @avatar)
        if @service.update_attributes(params[:user], params[:avatar_file])
          flash[:notice] = t(:user_was_successfully_updated) 
          format.html { redirect_to user_profile_path(@user.try(:username)) }
        else
          @avatar = @service.avatar
          format.html { render :action => "edit" }
        end
      #no avatar file
      else
        if @user.update_attributes(params[:user])
          flash[:notice] =  t(:user_was_successfully_updated) 
          format.html { redirect_to user_profile_path(@user.try(:username)) }
        else
          format.html { render :action => "edit" }
        end
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end

  def link_user_accounts
    session[:logout] = nil
    if self.current_user.nil?
      user = User.find_by_fb_user(facebook_session.user)
      if user
        redirect_to root_url and return 
      end
      #register with fb
      User.create_from_fb_connect(facebook_session.user)
    else
      #connect accounts
      self.current_user.link_fb_connect(facebook_session) unless self.current_user.fb_user_id == facebook_session.user.id
    end
    redirect_to root_url 
  end


end
