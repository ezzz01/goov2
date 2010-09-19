class Concept < ActiveRecord::Base
  has_many :revisions, :dependent => :destroy
  has_many :wiki_references, :order => 'referenced_name'
  validates_presence_of :title
  validates_uniqueness_of :title
  
  def self.wikilog
    @@logfile ||= File.open(File.dirname(__FILE__) + "/../../log/wikilog.log", 'a')    
    @@logfile.sync = true
    CustomLogger.new(@@logfile)
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

