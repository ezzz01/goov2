class ConceptsController < ApplicationController
  authorize_resource
  before_filter :load_page
 
  def load_page
    @page_name = params['id'] ? params['id'].purify : nil
  end

  def index
    list
    if params[:category]
      @category = params[:category]
      @title = t(:all_pages_in_category) + " \"" + @category + "\""
      render :template => 'concepts/list'
    else
      @title = t(:wiki_start_page)
      render :template => 'concepts/first_page'
    end
  end

  def show
    @title = @page_name
    @concept = Concept.find_by_title(@page_name)
    begin
      @author = User.find(@concept.revisions.last.author_id) 
    rescue
      @author =nil 
    end
    if @concept.nil?
      flash[:notice] = t(:no_such_word)
      redirect_to(concept_url) 
    else 
      @renderer = PageRenderer.new(@concept.revisions.last)
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @concept }
      end
    end
  end

  # GET /concepts/new
  # GET /concepts/new.xml
  def new
    @include_wiki_form = :true
    @concept = Concept.new
    #if we came here over the wiki_link, the title can already be set 
    @concept.title = params[:title] if params[:title]
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @concept }
    end
  end

  # GET /concepts/1/edit
  def edit
    @include_wiki_form = :true
    @concept = Concept.find(params[:id])
    @title = t(:edit_page) + " \"" + @concept.title + "\""
    @current_revision = (@concept.revisions.empty?)? "" : @concept.revisions.last.content
    @current_revision = @current_revision.gsub(/^Kategorijos:(.*)$/, "")
    @concept.category_list = @concept.categories.join(", ")
  end

  # POST /concepts
  # POST /concepts.xml
  def create
    @concept = Concept.new(params[:concept])
    if (@concept.revisions.empty?)
      @concept.revisions.build(:content => "")
    end
    @concept.revisions.last.author = current_user
    @concept.revisions.last.content += "\n\nKategorijos: " + params[:concept][:category_list]
    @concept.revisions.last.concept = @concept
    renderer = PageRenderer.new
    renderer.revision = @concept.revisions.last
    rendering_result = renderer.render(update_references = true)
    wiki_references = renderer.update_references(rendering_result)
    respond_to do |format|
      if @concept.save && @concept.update_attribute("wiki_references", wiki_references) 
        CustomLogger.wikilog.info(I18n.t(:added_new_concept, :user => current_user.username, :title => @concept.title))
        flash[:notice] = t(:page_was_successfully_created) 
        format.html { redirect_to(concept_path(@concept.title)) }
        format.js { 
          if (params[:concept_type] == "country")
            render :update do |page|
               page.replace_html 'country', :partial => 'activities/countries',  :object => Concept.find_all_countries
               page << "lightbox.prototype.deactivate();"
               page << "initialize();" 
               flash.discard
            end
          elsif (params[:concept_type] == "organization")
            render :update do |page|
               orgs = Concept.find_all_organizations_in_country(params[:concept][:country_id])
          #FIXME - turi buti atskiras metodas, kisti i helperi
               universities = Hash.new
               if orgs.length > 0
                 temp = orgs.each { |org|
                 universities[org.title] = org.id }
               end
               orgs = Hash.new
               orgs[t(:university)] = universities unless universities.empty?
          #END FIXME
               page.replace_html 'organization', :partial => 'activities/organizations', :locals => {:id => params[:concept][:country_id], :organizations => orgs } 
               page << "lightbox.prototype.deactivate();"
               page << "initialize();" 
               flash.discard
            end
          elsif (params[:concept_type] == "study_program")
            render :update do |page|
               page.replace_html 'study_program', :partial => 'activities/study_programs', :locals => {:id => params[:concept][:subject_area_id], :object => Concept.find_all_study_programs_in_subject_area(params[:concept][:subject_area_id])} 
               page << "lightbox.prototype.deactivate();"
               page << "initialize();" 
               flash.discard
            end
          end
          }
      else
        format.html { render :action => "new" }
        format.js { 
              render :update do |page|
              page << "alert(' #{t(:error_saving_possibly_duplicate)}');"
              page << "lightbox.prototype.deactivate();"
              flash.discard
            end
        }
      end
    end
  end

  # PUT /concepts/1
  # PUT /concepts/1.xml
  def update
    #FIXME reikia refactorinti ir viska sukisti i modeli (fat models lean controllers)
    @concept = Concept.find(params[:id])
    @updates = params[:concept]
    @updates[:new_revision][:author_id] = current_user.id
    #add categories from separate input field
    @updates[:new_revision][:content] += "\n\nKategorijos: " + @updates[:category_list]
    renderer = PageRenderer.new
    revision = Revision.new(@updates[:new_revision]) 
    revision.concept = @concept
    renderer.revision = revision
    rendering_result = renderer.render(update_references = true)
    wiki_references = renderer.update_references(rendering_result)
    respond_to do |format|
      if @concept.update_attributes(@updates) && @concept.update_attribute("wiki_references", wiki_references) 
        CustomLogger.wikilog.info(I18n.t(:edited_concept, :user => current_user.username, :title => @concept.title))
        flash[:notice] = t(:page_was_successfully_updated)
        format.html { redirect_to(concept_path(@concept.title)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /concepts/1
  # DELETE /concepts/1.xml
  def destroy
    @concept = Concept.find(params[:id])
    @concept.destroy
    respond_to do |format|
      format.html { redirect_to(concepts_url) }
    end
  end

  def concept_exists?(name)

  end

  def list
    parse_category
    @page_names_that_are_wanted = @concepts_in_category.wanted_concepts
    @pages_that_are_orphaned = @concepts_in_category.orphaned_concepts
  end
 
  def create_country
     @country = Concept.new
     respond_to do |format|
      format.html { render :partial => "create_country", :layout => "modal", :locals => {:categories => "Šalys" } }
    end
  end 

  def create_organization
     @organization = Concept.new
     @country = Concept.find(:first, :conditions => ["id = ?", params[:country_id]])
     respond_to do |format|
      format.html { render :partial => "create_organization", :layout => "modal", :locals => { :categories => "Organizacijos, " + @country.title, :country_id => params[:country_id] } }
    end
  end 

  def create_study_program
    @study_program = Concept.new
    @subj_area = Concept.find(:first, :conditions => ["id = ?", params[:subject_area_id]])
    respond_to do |format|
      format.html { render :partial => "create_study_program", :layout => "modal", :locals => { :categories => "Studijų programos, " + @subj_area.title, :subject_area_id => params[:subject_area_id] } }
    end
  end

  private

 def parse_category
   @categories = WikiReference.list_categories.sort
   @category = params['category']
   if @category
     @set_name = "Kategorijos '#{@category}'"
     concepts = WikiReference.concepts_in_category(@category).sort.map { |concept_title| Concept.find_by_title(concept_title) }
     @concepts_in_category = ConceptSet.new(concepts)
   else
     # no category specified, return start page 
     @set_name = t(:wiki_start_page) 
     @concepts_in_category = ConceptSet.new 
   end
  end


end

