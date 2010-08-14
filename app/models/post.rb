class Post < ActiveRecord::Base
  include ApplicationHelper

  acts_as_taggable
  belongs_to :user
  has_many :comments, :order => "created_at", :dependent => :destroy
  alias_attribute :published, :created_at
  alias_attribute :content, :body
  attr_accessor :link
  attr_accessor :url
  attr_accessor :updating_feed

  validates_presence_of :body unless :updating_feed
  validates_length_of :title, :maximum => 100, :allow_nil => true 
  validates_length_of :body, :maximum => DB_TEXT_MAX_LENGTH
  validates_uniqueness_of :body, :scope => :title unless :updating_feed

  def duplicate?
    post = Post.find_by_user_id_and_title_and_body(user_id, title, body)
    self.id = post.id unless post.nil?
    not post.nil?
  end

end

