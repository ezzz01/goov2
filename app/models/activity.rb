class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :country, :class_name => "Concept"
  belongs_to :organization, :class_name => "Concept"
  belongs_to :study_program, :class_name => "Concept"
  belongs_to :exchange_program, :class_name => "Concept"
  belongs_to :activity_area, :class_name => "Concept"
  
  def self.model_name
    name = "activity"
    name.instance_eval do
      def plural;   pluralize;   end
      def singular; singularize; end
    end
    return name
  end

end
