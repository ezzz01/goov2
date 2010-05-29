class Answer < ActiveRecord::Base
  belongs_to :question
  belongs_to :user

  has_many :votes, :as => :voteable, :dependent => :destroy

  validates_presence_of :body, :question
  validates_length_of :body, :maximum => DB_TEXT_MAX_LENGTH
  validates_uniqueness_of :body, :scope => [:question_id, :user_id] 

  def duplicate?
    c = Answer.find_by_question_id_and_body(question, body)
    self.id = c.id unless c.nil?
    not c.nil?
  end

  def votes_for
    votes = Vote.find(:all, :conditions => [ "voteable_id = ? AND vote = ?", id, 1 ])
    votes.size
  end

  def votes_against
    votes = Vote.find(:all, :conditions => [ "voteable_id = ? AND vote = ?", id, '-1'])
    votes.size
  end

  def votes_count
    self.votes.size
  end
 
end
