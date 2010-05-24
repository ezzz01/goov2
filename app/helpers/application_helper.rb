# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def nav_link(text, controller, action="index")
    link_to_unless_current text, :id => nil, :controller => controller, :action => action
  end

  def profile_for(user)
    if user.nil?
      content_tag(:span, :class => "gooutuser") do 
        return t(:anonymous)
      end
    end
    if user.respond_to?('username')
      content_tag(:span, :class => "gooutuser") do 
        link_to(user.username, user_profile_path(user.try(:username)))
      end
    else
      user = User.find_by_username(user)
      content_tag(:span, :class => "gooutuser") do 
        link_to user.try(:username), user_profile_path(user.try(:username))
      end
    end
  end

  def find_user(params)
    if params[:user] 
      @user = User.find_by_username(params[:user])
    elsif params[:id]
        if User.exists?(params[:id])
          @user = User.find(params[:id]) 
        else
          flash[:notice] = t(:no_such_user)
          redirect_to users_path 
        end
    else
      flash[:notice] = t(:no_such_user)
      redirect_to users_path
    end
  end
 
  def avatar_for(user, size = :large)
    if user.avatar
      avatar_image = user.avatar.public_filename(size)
        link_to image_tag(avatar_image), user_profile_path(user.try(:username)) 
    else
      image_tag("blank-cover-#{size}.png" )
    end
  end

end
