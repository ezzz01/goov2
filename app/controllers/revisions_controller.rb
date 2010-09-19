class RevisionsController < ApplicationController
  load_and_authorize_resource
  # GET /revisions
  # GET /revisions.xml
  def index
    @revisions = Revision.find_all_by_concept_id(params[:concept_id], :order => :created_at)
    if @revisions.empty?
      flash[:notice] = t(:no_such_word)
      redirect_to concepts_path
    else 
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @revisions }
      end
    end
  end

  # GET /revisions/1
  # GET /revisions/1.xml
  def show
    @revision = Revision.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @revision }
    end
  end

  # DELETE /revisions/1
  # DELETE /revisions/1.xml
  def destroy
    @revision = Revision.find(params[:id])
    @revision.destroy

    respond_to do |format|
      format.html { redirect_to(revisions_url) }
      format.xml  { head :ok }
    end
  end
end

