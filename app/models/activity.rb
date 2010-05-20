class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :country
  belongs_to :organization
  
  def country_id
  end

  def self.model_name
    name = "activity"
    name.instance_eval do
      def plural;   pluralize;   end
      def singular; singularize; end
    end
    return name
  end

end
