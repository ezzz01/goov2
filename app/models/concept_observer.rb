# This class maintains the state of wiki references for newly created or newly deleted concepts
class ConceptObserver < ActiveRecord::Observer

  def before_create(concept)
    renderer = PageRenderer.new
    renderer.revision = concept.revisions.last
    rendering_result = renderer.render(update_references = true)
    concept.wiki_references = renderer.update_references(rendering_result)
  end

  def after_create(concept)
    WikiReference.update_all("link_type = '#{WikiReference::LINKED_PAGE}'", 
        ['referenced_name = ?', concept.title])
  end

  def before_update(concept)
#   WikiReference.delete_all ['concept_id = ?', concept.id]
  end

  def after_update(concept)
#   WikiReference.update_all("link_type = '#{WikiReference::LINKED_PAGE}'", 
#       ['referenced_name = ?', concept.title])
  end

  def before_destroy(concept)
    WikiReference.delete_all ['concept_id = ?', concept.id]
    WikiReference.update_all("link_type = '#{WikiReference::WANTED_PAGE}'", 
        ['referenced_name = ?', concept.title])
  end

end

