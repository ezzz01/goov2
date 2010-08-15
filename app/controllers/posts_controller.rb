class PostsController < ApplicationController
  load_and_authorize_resource
  require 'feedzirra'

  def index
    @user = find_user(params) 
    @title = t(:blog_posts, :username => @user.try(:username) )
    @blog_url = @user.blog_url 

    if (params[:tag_id])
        @posts = @user.posts.find_tagged_with(params[:tag_id], :order => "created_at DESC", :conditions => "deleted = 0" )
        @posts = @posts.paginate(:per_page => 20)
    else
        @posts = Post.find_all_by_user_id(@user.id, :order => "created_at DESC", :conditions => "deleted = 0") 
        @posts = @posts.paginate(:per_page => 20)
    end

    @tags = @user.posts.tag_counts.sort{|x, y| x.name.downcase <=> y.name.downcase }

    respond_to do |format|
      format.html 
    end
  end

  def show
    @post = Post.find(params[:id])
    @tags = @post.tag_list
    @title = @post.user.nil? ? t(:anonymous) : @post.user.username + " - " + @post.title
    if params[:mode] == "comment"
      @comment = Comment.new(:user => current_user) 
    end
    respond_to do |format|
      format.html 
    end
  end

  def new
    @include_post_form = :true
    @post = Post.new
    @post.user = current_user 
    @title = t(:add_new_post)
    respond_to do |format|
      format.html
    end
  end

  def edit
    @include_post_form = :true
    @post = Post.find(params[:id])
    @title = t(:edit_post, :title => @post.title)
  end

  def create
    @post = Post.new(params[:post])
    @post.user = current_user
    respond_to do |format|
      if @post.duplicate? or @post.save 
        flash[:notice] = t(:post_created_successfully) 
        format.html { redirect_to blog_url(@post.user.username) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @post = Post.find(params[:id])
    respond_to do |format|
      if @post.update_attributes(params[:post])
        flash[:notice] = t(:post_updated_successfully) 
        format.html { redirect_to post_url(@post.user.username, @post) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy

    respond_to do |format|
      format.html { redirect_to(user_posts_url(@post.user_id)) }
    end
  end

  def mark_as_deleted
    @post = Post.find(params[:post_id])
    if can? :update, @post
      if @post.update_attribute(:deleted, 1)
        respond_to do |format|
          format.js
        end
      end
    end
  end
end

