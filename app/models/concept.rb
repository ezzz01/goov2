class Concept < ActiveRecord::Base
  has_many :revisions, :dependent => :destroy
  has_many :wiki_references, :order => 'referenced_name'
  attr_accessor :category_list
  validates_presence_of :title
  validates_uniqueness_of :title
  
  def self.wikilog
    @@logfile ||= File.open(File.dirname(__FILE__) + "/../../log/wikilog.log", 'a')    
    @@logfile.sync = true
    CustomLogger.new(@@logfile)
  end

  def self.find_all_countries
    Concept.find(:all, :order => "title", :joins => "join wiki_references on wiki_references.concept_id = concepts.id", :conditions => ["wiki_references.link_type = 'C' AND wiki_references.referenced_name = ?", "Šalys"])
  end

  def self.find_all_subject_areas
    Concept.find(:all, :order => "title", :joins => "join wiki_references on wiki_references.concept_id = concepts.id", :conditions => ["wiki_references.link_type = 'C' AND wiki_references.referenced_name = ?", "Studijų sritys"])
  end

  def self.find_all_organizations_in_country(country_id)
    Concept.find_by_sql("SELECT conc.* FROM (concepts conc JOIN wiki_references as ref1 ON ref1.concept_id = conc.id) JOIN wiki_references as ref2 ON ref2.concept_id = conc.id WHERE ref1.link_type = 'C' AND ref1.referenced_name = (select concepts.title FROM concepts WHERE concepts.id = " + country_id.to_s + ") AND ref2.referenced_name = 'Organizacijos'")
  end

  def new_revision=(revision_attributes)
   revisions.build(revision_attributes)
 end

  def references
#   web.select.pages_that_reference(name)
  end

  def wiki_words
    wiki_references.select { |ref| ref.wiki_word? }.map { |ref| ref.referenced_name }
  end

  def categories
    wiki_references.select { |ref| ref.category? }.map { |ref| ref.referenced_name }
  end

  def linked_from
#   web.select.pages_that_link_to(name)
  end

  def redirects
    wiki_references.select { |ref| ref.redirected_page? }.map { |ref| ref.referenced_name }
  end  

  def included_from
#   web.select.pages_that_include(name)
  end

  def plain_name
    title.escapeHTML
#   web.brackets_only? ? name.escapeHTML : WikiWords.separate(name).escapeHTML
  end



end

