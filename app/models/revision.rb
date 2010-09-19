class Revision < ActiveRecord::Base
  belongs_to :author, :class_name => 'User'
  belongs_to :concept
#  validates_presence_of :author_id
#  validates_presence_of :concept_id
end

