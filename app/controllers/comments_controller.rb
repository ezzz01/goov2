class CommentsController < ApplicationController
 load_and_authorize_resource
 before_filter :load_post, :only => ["index", "show", "new", "create"]

 
  def index
    redirect_to user_post_path(@post.user_id, @post) 
  end

  def show
    redirect_to user_post_path(@post.user_id, @post) 
  end

  def edit 
    redirect_to user_post_path(@post.user_id, @post) 
  end

  def new
    @comment = @post.comments.build
    @parent_comment = params[:comment_id]
    respond_to do |format|
      format.html { redirect_to user_post_path(@post.user_id, @post) }
      format.js 
    end
  end

  def create
    @comment = @post.comments.build(params[:comment])
    @comment.user_id = (current_user.nil?)? nil : current_user.id 

    respond_to do |format|
      if @comment.duplicate? or @comment.save
        params[:mode] = nil
        format.html { redirect_to post_path(@post.user.username, @post) }
        format.js 
      else
        format.html { render :action => "new" }
        format.js { render :nothing => true}
      end
    end
  end

  def update
    @comment = Comment.find(params[:id])
    @post = @comment.post 
    redirect_to user_post_path(@post.user_id, @post) 

#    respond_to do |format|
#      if @comment.update_attributes(params[:comment])
#        flash[:notice] = 'Comment was successfully updated.'
#        format.html { redirect_to([@post, @comment]) }
#        format.xml  { head :ok }
#      else
#        format.html { render :action => "edit" }
#        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
#      end
#    end

  end

  def destroy
    @comment = Comment.find(params[:id])
    @post = @comment.post
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to(post_comments_url(@post)) }
      format.js
    end
  end

  private

  def load_post
    @post = Post.find(params[:post_id])
  end

end

