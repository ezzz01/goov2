class ActivitiesController < ApplicationController
  load_and_authorize_resource
  include ApplicationHelper

  def new 
    @countries = Concept.find_all_countries
    @subject_areas = Concept.find_all_subject_areas
    @activity = Activity.new
    respond_to do |format|
      format.js 
    end
  end

  def edit

  end

  def create
    if(params[:my_type] == "full_study")
        @activity = FullStudy.new(params[:activity])
    elsif(params[:my_type] == "exchange_study")
        @activity = ExchangeStudy.new(params[:activity])
    elsif(params[:my_type] == "internship")
        @activity = Internship.new(params[:activity])
    end
    @user = current_user 
    @activity.user_id = @user.id
    respond_to do |format|
      if @activity.save
        format.js 
      else
        flash[:notice] = t(:error_on_saving)
      end
    end
  end

  def destroy
    @activity = Activity.find(params[:id])
    @activity.destroy

    respond_to do |format|
      format.html 
      format.js 
    end
  end


  def update_organizations
    orgs = load_organizations(params[:country_id])
	render :update do |page|
        if orgs.blank?
            page.replace_html 'organization', :partial => 'organizations', :locals => {:id => params[:country_id], :organizations => nil}
        else 
            page.replace_html 'organization', :partial => 'organizations', :locals => {:id => params[:country_id], :organizations => orgs}
            page[:activity_organization_id].set_style :width => "400px"
        end
        page << "initialize();" 
	end
  end


  def update_study_programs
	subject_area = SubjectArea.find_by_id(params[:subject_area_id], :include => :study_programs, :order => 'concepts.title', :conditions => [ "concepts.pending = 0 OR concepts.added_by = ?", session[:user_id] ])
	render :update do |page|
        if subject_area.blank?
            page.replace_html 'study_program', :partial => 'study_programs', :locals => {:id => params[:subject_area_id] }, :object => nil
        else
            page.replace_html 'study_program', :partial => 'study_programs', :locals => {:id => params[:subject_area_id] }, :object => subject_area.study_programs
            page[:activity_study_program_id].set_style :width => "400px"
        end
        page << "initialize();" 
	end
  end

  def update_fields
	    render :update do |page|
            if (params[:activity_type] == "full_study")
                page.hide "exchange_program"
                page.hide "activity_area"
                page.show "subject_area"
                page.show "study_program"
            elsif (params[:activity_type] == "exchange_study")
                exchange_programs = ExchangeProgram.find(:all, :order => :title)
                page.replace_html 'exchange_program', :partial => 'exchange_programs', :locals => {}, :object => exchange_programs 
                page[:activity_exchange_program_id].set_style :width => "400px" if !exchange_programs.blank?
                page[:exchange_program].set_style :display => "block";
                page.hide "activity_area"
                page.show "subject_area"
                page.show "study_program"
            elsif (params[:activity_type] == "internship")
                activity_areas = ActivityArea.find(:all, :order => :title)
                page.replace_html 'activity_area', :partial => 'activity_areas', :locals => {}, :object => activity_areas 
                page[:activity_activity_area_id].set_style :width => "400px" if !activity_areas.blank?
                page.hide "exchange_program"
                page.show "activity_area"
                page.hide "subject_area"
                page.hide "study_program"
            end
            page << "initialize();" 
        end
  end

  end
