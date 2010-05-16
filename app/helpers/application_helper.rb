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

 
end
