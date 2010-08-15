module PostsHelper

  def post_link(*args)
    post = args[0]
    if args.size == 1
      if post.user.nil?
        link_to post.title, user_post_path(post.user_id, post)
      else
        link_to post.title, post_path(post.try(:user).try(:username), post.id) 
      end

    elsif args.size == 2
        
      if post.user.nil?
        link_to t(:new_post_comment), user_post_path(post.user_id, post, :mode => "comment")
      else
        link_to t(:new_post_comment), post_path(post.try(:user).try(:username), post.id, :mode => "comment") 
      end
    end

    end

end

