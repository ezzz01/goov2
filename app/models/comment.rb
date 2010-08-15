class Comment < ActiveRecord::Base
  belongs_to :post
  belongs_to :in_reply_to, :class_name => "Comment"
  has_many :replies, :class_name => "Comment", :foreign_key => "in_reply_to_id"
  belongs_to :user

  validates_presence_of :body, :post
  validates_length_of :body, :maximum => DB_TEXT_MAX_LENGTH
  validates_uniqueness_of :body, :scope => [:post_id, :user_id] 

  def duplicate?
    c = Comment.find_by_post_id_and_user_id_and_body(post, user, body)
    self.id = c.id unless c.nil?
    not c.nil?
  end

  def authorized?(user)
    post.user == user or comment.user == user
  end
end

