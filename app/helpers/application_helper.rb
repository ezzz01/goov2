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
    elsif params[:user_id]
       if User.exists?(params[:user_id])
          @user = User.find_by_id(params[:user_id]) 
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



####################################
# instiki helpers
####################################

  # Accepts a container (hash, array, enumerable, your type) and returns a string of option tags. Given a container 
  # where the elements respond to first and last (such as a two-element array), the "lasts" serve as option values and
  # the "firsts" as option text. Hashes are turned into this form automatically, so the keys become "firsts" and values
  # become lasts. If +selected+ is specified, the matching "last" or element will get the selected option-tag.
  #
  # Examples (call, result):
  #   html_options([["Dollar", "$"], ["Kroner", "DKK"]])
  #     <option value="$">Dollar</option>\n<option value="DKK">Kroner</option>
  #
  #   html_options([ "VISA", "Mastercard" ], "Mastercard")
  #     <option>VISA</option>\n<option selected>Mastercard</option>
  #
  #   html_options({ "Basic" => "$20", "Plus" => "$40" }, "$40")
  #     <option value="$20">Basic</option>\n<option value="$40" selected>Plus</option>

  def html_options(container, selected = nil)
    container = container.to_a if Hash === container
  
    html_options = container.inject([]) do |options, element| 
      if element.is_a? Array
        if element.last != selected
          options << "<option value=\"#{element.last}\">#{element.first}</option>"
        else
          options << "<option value=\"#{element.last}\" selected=\"selected\">#{element.first}</option>"
        end
      else
        options << ((element != selected) ? "<option>#{element}</option>" : "<option selected>#{element}</option>")
      end
    end
    
    html_options.join("\n")
  end

  # Creates a hyperlink to a Wiki page, without checking if the concept exists or not
  def link_to_existing_concept(concept, text = nil, html_options = {})
    link_to(
        text || concept.plain_name, 
        {:action => 'show', :id => concept.title, :only_path => true},
        html_options)
  end
  
  # Creates a hyperlink to a Wiki page, or to a "new page" form if the concept doesn't exist yet
  def link_to_concept(concept_title, text = nil, options = {})
    UrlGenerator.new(@controller).make_link(concept_title, text)
  end

  def author_link(concept, options = {})
#   UrlGenerator.new(@controller).make_link(concept.author.name, nil, options)
  end

  # Create a hyperlink to a particular revision of a Wiki page
  def link_to_revision(concept, revision_number, text = nil, mode = nil, html_options = {})
    revision_number == concept.revisions.size ?
      link_to(
        text || concept.plain_name,
            {:action => 'show', :id => concept.title,
               :mode => mode}, html_options) :
      link_to(
        text || concept.plain_name + "(rev # #{revision_number})",
            {:action => 'revision', :id => concept.title,
              :rev => revision_number, :mode => mode}, html_options)
  end

  # Create a hyperlink to the history of a particular Wiki page
  def link_to_history(concept, text = nil, html_options = {})
    link_to(
        text || concept.plain_name + "(history)",
            {:action => 'history', :id => concept.title},
            html_options)
  end

  def base_url
    #home_page_url = url_for :controller => 'admin', :action => 'create_system', :only_path => true
#   home_page_url.sub(%r-/create_system/?$-, '')
  end

  # Creates a menu of categories
  def categories_menu
    if @categories.empty?
      ''
    else 
      "<div id=\"categories\">\n" +
      '<strong>Categories</strong>:' +
      '[' + link_to_unless_current('Any', :action => self.action_name, :category => nil) + "]\n" +
      @categories.map { |c| 
        link_to_unless_current(c, :action => self.action_name, :category => c)
      }.join(', ') + "\n" +
      '</div>'
    end
  end

  def wiki_first_page_menu
      @categories.map { |c| 
        link_to(c.capitalize, :action => self.action_name, :category => c)
      }.join('<br />') 
  end

  # Performs HTML escaping on text, but keeps linefeeds intact (by replacing them with <br/>)
  def escape_preserving_linefeeds(text)
    h(text).gsub(/\n/, '<br/>').as_utf8
  end

  def format_date(date, include_time = true)
    # Must use DateTime because Time doesn't support %e on at least some platforms
    if include_time
      DateTime.new(date.year, date.mon, date.day, date.hour, date.min, date.sec).strftime("%B %e, %Y %H:%M:%S")
    else
      DateTime.new(date.year, date.mon, date.day).strftime("%B %e, %Y")
    end
  end

  def rendered_content(concept)
    PageRenderer.new(concept.revisions.last).display_content
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



end
