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
    @activity = Activity.new(params[:activity])
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
    orgs = Concept.find_all_organizations_in_country(params[:country_id]) 

    universities = Hash.new
    if orgs.length > 0
      temp = orgs.each { |org|
        universities[org.title] = org.id }
    end

    orgs = Hash.new
    orgs[t(:university)] = universities unless universities.empty?

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
	study_programs = Concept.find_all_study_programs_in_subject_area(params[:subject_area_id])
	render :update do |page|
        if study_programs.empty?
            page.replace_html 'study_program', :partial => 'study_programs', :locals => {:id => params[:subject_area_id] }, :object => nil
        else
            page.replace_html 'study_program', :partial => 'study_programs', :locals => {:id => params[:subject_area_id] }, :object => study_programs
            page[:activity_study_program_id].set_style :width => "400px"
        end
        page << "initialize();" 
	end
  end

  def update_fields
	    render :update do |page|
            #full_study
            if (params[:activity_type].to_sym == ACTIVITIES[0])
                page.hide "exchange_program"
                page.hide "activity_area"
                page.show "subject_area"
                page.show "study_program"
            #exchange_study
            elsif (params[:activity_type].to_sym == ACTIVITIES[1]) 
                exchange_programs = Concept.find_all_exchange_programs
                page.replace_html 'exchange_program', :partial => 'exchange_programs', :locals => {}, :object => exchange_programs 
                page[:activity_exchange_program_id].set_style :width => "400px" if !exchange_programs.blank?
                page[:exchange_program].set_style :display => "block";
                page.hide "activity_area"
                page.show "subject_area"
                page.show "study_program"
            #internship
            elsif (params[:activity_type].to_sym == ACTIVITIES[2]) 
                activity_areas = Concept.find_all_activity_areas
                page.replace_html 'activity_area', :partial => 'activity_areas', :locals => {}, :object => activity_areas 
                page[:activity_activity_area_id].set_style :width => "400px" if !activity_areas.blank?
                page.hide "exchange_program"
                page.show "activity_area"
                page.hide "subject_area"
                page.hide "study_program"
            #voluneer
            elsif (params[:activity_type].to_sym == ACTIVITIES[3]) 
                activity_areas = Concept.find_all_activity_areas
                page.replace_html 'activity_area', :partial => 'activity_areas', :locals => {}, :object => activity_areas 
                page[:activity_activity_area_id].set_style :width => "400px" if !activity_areas.blank?
                page.hide "exchange_program"
                page.show "activity_area"
                page.hide "subject_area"
                page.hide "study_program"
             #other
             elsif (params[:activity_type].to_sym == ACTIVITIES[4]) 
                page.hide "exchange_program"
                page.hide "activity_area"
                page.hide "subject_area"
                page.hide "study_program"
                page.hide "study_program"
                page.hide "organization"
            end
            page << "initialize();" 
        end
  end

  end
