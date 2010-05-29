class Question < ActiveRecord::Base
  acts_as_taggable
  belongs_to :user
  has_many :answers, :order => "created_at", :dependent => :destroy
  validates_presence_of :body
  validates_length_of :body, :maximum => DB_TEXT_MAX_LENGTH
  validates_uniqueness_of :body

  def duplicate?
    question = Question.find_by_user_id_and_body(user_id, body)
    self.id = question.id unless question.nil?
    not question.nil?
  end

  def sorted_answers(limit=10000)
    Answer.find_by_sql ["SELECT answers.*, IFNULL(sum(vote), 0) as rating FROM `answers` LEFT JOIN votes on votes.voteable_id = answers.id where answers.question_id = ? group by answers.id order by rating DESC LIMIT ?", self.id, limit]
  end

end
