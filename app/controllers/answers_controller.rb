class AnswersController < ApplicationController
  load_and_authorize_resource
  before_filter :load_question, :only => ["index", "new", "create"]
  before_filter :find_answer, :only => ["vote_for", "vote_against", "unvote_for", "unvote_against"]

  def index
    redirect_to question_path(@question)
  end

  def show
    @answer = Answer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @answer }
    end
  end

  def new
    respond_to do |format|
      format.js 
    end
  end

  def edit
    @answer = Answer.find(params[:id])
  end

  def create
      @answer = @question.answers.build(params[:answer])
      @answer.user_id = (current_user.nil?)? nil : current_user.id 
      respond_to do |format|
        if @answer.duplicate? or @answer.save
          format.html { redirect_to root_url }
          format.js 
        else
          format.html { render :action => "new" }
          format.js { render :nothing => true}
        end
      end
  end

  def update
    @answer = Answer.find(params[:id])

    respond_to do |format|
      if @answer.update_attributes(params[:answer])
        flash[:notice] = 'Answer was successfully updated.'
        format.html { redirect_to(@answer) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @answer.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @answer = Answer.find(params[:id])
    @answer.destroy

    respond_to do |format|
      format.js
    end
  end
 
  def vote_for
    vote_old = Vote.find(:first, :conditions => [ "voteable_id = ? AND user_id = ?", @answer.id, current_user.id ])
    @answer.votes.delete(vote_old) if vote_old
    vote = Vote.new(:vote => 1, :user => try(:current_user))
    @answer.votes << vote
    if @answer.save!
      rerender_vote_buttons(@answer)
    end
  end

  def vote_against
    vote_old = Vote.find(:first, :conditions => [ "voteable_id = ? AND user_id = ?", @answer.id, current_user.id ])
    @answer.votes.delete(vote_old) if vote_old
    vote = Vote.new(:vote => "-1", :user => try(:current_user))
    @answer.votes << vote
    if @answer.save!
      rerender_vote_buttons(@answer)
    end
  end

  def unvote_for
    vote = Vote.find(:first, :conditions => [ "voteable_id = ? AND vote = ? AND user_id = ? ", @answer.id, 1, current_user.id ])
    @answer.votes.delete(vote) if vote
    if @answer.save!
      rerender_vote_buttons(@answer)
    end
  end

  def unvote_against
    vote = Vote.find(:first, :conditions => [ "voteable_id = ? AND vote = ? AND user_id = ? ", @answer.id, "-1", current_user.id ])
    @answer.votes.delete(vote) if vote
    if @answer.save!
      rerender_vote_buttons(@answer)
    end
  end

  private

  def load_question
    @question = Question.find(params[:question_id])
  end

  def find_answer
    @answer = Answer.find(params[:answer_id])
  end

  def rerender_vote_buttons(answer)
     @question = answer.question
     @sorted_answers = @question.sorted_answers

     render :update do |page|
        page.replace_html "votes_for_#{answer.id}", answer.votes_for 
        page.replace_html "votes_against_#{answer.id}", answer.votes_against
        page.replace_html "answers_for_question_#{@question.id}",
              :partial => "answers/answer",
              :collection => @sorted_answers, :locals => {:long => :long }
        page.replace_html "votebutton_for_#{answer.id}", :partial => 'answers/vote_logic', :locals => {:forr_against => :forr, :answer => answer }
        page.replace_html "votebutton_against_#{answer.id}", :partial => 'answers/vote_logic', :locals => {:forr_against => :against, :answer => answer }
      end
  end


end
