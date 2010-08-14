# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  require 'string'

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
 
  def avatar_for(user, size = :small)
    if user.nil?
      image_tag("blank-cover-#{size}.png" ) and return
    end
    if user.avatar
      if user.avatar.fb_avatar == true
        avatar_image = user.avatar.thumbnail 
      else
        avatar_image = user.avatar.public_filename(size)
      end 
      link_to image_tag(avatar_image), user_profile_path(user.try(:username)) 
    else
      image_tag("blank-cover-#{size}.png" )
    end
  end

 def hidden_div_if(condition, attributes = {}, &block)
    if condition
        attributes["style"] = "display: none"
    end
    content_tag("div", attributes, &block)
  end

  def truncate(text, *args)
    options = args.extract_options!
    options.reverse_merge!(:length => 30, :omission => "...")
    return text if text.num_chars <= options[:length]
    len = options[:length] - options[:omission].as_utf8.num_chars
    t = ''
    text.split.collect do |word|
      if t.num_chars + word.num_chars <= len
        t << word + ' '
      else 
        return t.chop + options[:omission]
      end
    end
  end

  def tag_cloud(tags, classes)
    return if tags.empty?
    
    max_count = tags.sort_by(&:count).last.count.to_f
    
    tags.each do |tag|
      index = ((tag.count / max_count) * (classes.size - 1)).round
      yield tag, classes[index]
    end
  end


end
