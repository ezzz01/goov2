# Container for a set of pages with methods for manipulation.

class ConceptSet < Array

  def initialize(concepts = nil, condition = nil)
    # if concepts is not specified, make a list of all concepts in the web
    if concepts.nil?
      super(Concept.all(:conditions => "goout_intern = 0"))
    # otherwise use specified concepts and condition to produce a set of concepts
    elsif condition.nil?
      super(concepts)
    else
      super(concepts.select { |concept| condition[concept] })
    end
  end

  def most_recent_revision
    self.map { |concept| concept.revised_at }.max || Time.at(0)
  end

  def by_title
    ConceptSet.new(sort_by { |concept| concept.title})
  end

  alias :sort :by_title

  def by_revision
    ConceptSet.new(sort_by { |concept| concept.revised_at }).reverse 
  end
  
  def concepts_that_reference(concept_title)
    all_referring_concepts = WikiReference.concepts_that_reference(concept_title)
    self.select { |concept| all_referring_concepts.include?(concept.title) }
  end
  
  def concepts_that_link_to(concept_title)
    all_linking_concepts = WikiReference.concepts_that_link_to(concept_title)
    self.select { |concept| all_linking_concepts.include?(concept.title) }
  end

  def concepts_that_include(concept_title)
    all_including_concepts = WikiReference.concepts_that_include(concept_title)
    self.select { |concept| all_including_concepts.include?(concept.title) }
  end

  def concepts_authored_by(author)
    all_concepts_authored_by_the_author = 
        concept.connection.select_all(sanitize_sql([
            "SELECT concept_id FROM revision WHERE author = '?'", author]))
    self.select { |concept| concept.authors.include?(author) }
  end

  def characters
    self.inject(0) { |chars,concept| chars += concept.content.size }
  end

  # Returns all the orphaned concepts in this concept set. That is,
  # concepts in this set for which there is no reference in the web.
  # The Homeconcept and author concepts are always assumed to have
  # references and so cannot be orphans
  # concepts that refer to themselves and have no links from outside are oprphans.
  def orphaned_concepts
   never_orphans = "" # web.authors + ['Homeconcept']
    self.select { |concept|
      if never_orphans.include? concept.title
        false
      else
        references = (WikiReference.concepts_that_reference(concept.title))# +  WikiReference.concepts_redirected_to(concept.title)).uniq
        references.empty? or references == [concept.title]
      end
    }
  end

  def concepts_in_category(category)
    self.select { |concept|
      WikiReference.concepts_in_category(category).map.include?(concept.title)
    }
  end

  # Returns all the wiki words in this concept set for which
  # there are no concepts in this concept set's web
  def wanted_concepts
    known_concepts = titles #(titles + redirected_titles).uniq
    wiki_words - known_concepts
  end

  def titles 
    self.map { |concept| concept.title }
  end
  
  def redirected_titles
#   self.wiki_words.select {|title| web.has_redirect_for?(name) }.uniq.sort
  end

  def wiki_words
    self.inject([]) { |wiki_words, concept|
        wiki_words + concept.wiki_words
    }.flatten.uniq.sort
  end

end

