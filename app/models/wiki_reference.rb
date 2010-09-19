class WikiReference < ActiveRecord::Base

  LINKED_PAGE = 'L'
  WANTED_PAGE = 'W'
  REDIRECTED_PAGE = 'R'
  INCLUDED_PAGE = 'I'
  CATEGORY = 'C'
  AUTHOR = 'A'
  FILE = 'F'
  WANTED_FILE = 'E'

  belongs_to :concept
  validates_inclusion_of :link_type, :in => [LINKED_PAGE, WANTED_PAGE, REDIRECTED_PAGE, INCLUDED_PAGE, CATEGORY, AUTHOR, FILE, WANTED_FILE]

  def referenced_name
    read_attribute(:referenced_name).as_utf8
  end

  def self.link_type(concept_title)
    if Concept.find_by_title(concept_title)
      LINKED_PAGE
    else
      WANTED_PAGE
    end
  end

  def self.concepts_that_reference(concept_title)
    query = 'SELECT title FROM concepts JOIN wiki_references ' +
      'ON concepts.id = wiki_references.concept_id ' +
      'WHERE wiki_references.referenced_name = ? ' +
      "AND wiki_references.link_type in ('#{LINKED_PAGE}', '#{WANTED_PAGE}', '#{INCLUDED_PAGE}') " 
    titles = connection.select_all(sanitize_sql([query, concept_title])).map { |row| row['title'] }
  end

  def self.concepts_that_link_to(concept_title)
    query = 'SELECT title FROM concepts JOIN wiki_references ' +
      'ON concepts.id = wiki_references.concept_id ' +
      'WHERE wiki_references.referenced_name = ? ' +
      "AND wiki_references.link_type in ('#{LINKED_PAGE}','#{WANTED_PAGE}') "
    titles = connection.select_all(sanitize_sql([query, concept_title])).map { |row| row['title'] }
  end
  
  def self.concepts_that_link_to_file(file_name)
    query = 'SELECT title FROM concepts JOIN wiki_references ' +
      'ON concepts.id = wiki_references.concept_id ' +
      'WHERE wiki_references.referenced_name = ? ' +
      "AND wiki_references.link_type in ('#{FILE}') "
    names = connection.select_all(sanitize_sql([query, file_name])).map { |row| row['name'] }
  end
  
  def self.concepts_that_include(concept_name)
    query = 'SELECT title FROM concepts JOIN wiki_references ' +
      'ON concepts.id = wiki_references.concept_id ' +
      'WHERE wiki_references.referenced_name = ? ' +
      "AND wiki_references.link_type = '#{INCLUDED_PAGE}' "
    names = connection.select_all(sanitize_sql([query, concept_name])).map { |row| row['name'] }
  end

  def self.concepts_redirected_to(concept_name)
    names = []
    redirected_concepts = []
    concept = Concept.find_by_title(concept_name)
    redirected_concepts.concat concept.redirects
    redirected_concepts.concat Thread.current[:concept_redirects][concept] if
            Thread.current[:concept_redirects] && Thread.current[:concept_redirects][concept]
    redirected_concepts.uniq.each { |name| names.concat self.concepts_that_reference(web, name) }
    names.uniq    
  end

  def self.concept_that_redirects_for(concept_name)
    query = 'SELECT title FROM concepts JOIN wiki_references ' +
      'ON concepts.id = wiki_references.concept_id ' +
      'WHERE wiki_references.referenced_name = ? ' +
      "AND wiki_references.link_type = '#{REDIRECTED_PAGE}' "
    row = connection.select_one(sanitize_sql([query, concept_name]))
    row['name'].as_utf8 if row
  end

  def self.concepts_in_category(category)
    query = 
      "SELECT title FROM concepts JOIN wiki_references " +
      "ON concepts.id = wiki_references.concept_id " +
      "WHERE wiki_references.referenced_name = ? " +
      "AND wiki_references.link_type = '#{CATEGORY}' " 
    names = connection.select_all(sanitize_sql([query, category])).map { |row| row['title'].as_utf8 }
  end
  
  def self.list_categories
    query = "SELECT DISTINCT wiki_references.referenced_name " +
      "FROM wiki_references LEFT OUTER JOIN concepts " +
      "ON wiki_references.concept_id = concepts.id " +
      "WHERE wiki_references.link_type = '#{CATEGORY}' " 
    connection.select_all(query).map { |row| row['referenced_name'].as_utf8 }
  end

  def wiki_word?
    linked_concept? or wanted_concept?
  end

  def wiki_link?
    linked_concept? or wanted_concept? or file? or wanted_file?
  end

  def linked_concept?
    link_type == LINKED_PAGE
  end

  def redirected_concept?
    link_type == REDIRECTED_PAGE
  end

  def wanted_concept?
    link_type == WANTED_PAGE
  end

  def included_concept?
    link_type == INCLUDED_PAGE
  end
  
  def file?
    link_type == FILE
  end
  
  def wanted_file?
    link_type == WANTED_FILE
  end

  def category?
    link_type == CATEGORY
  end

end

