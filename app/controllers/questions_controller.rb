class QuestionsController < ApplicationController
  load_and_authorize_resource

  def index
    if(params[:tag])
      @questions = Question.find_tagged_with(params[:tag], :order => "created_at DESC")
      @questions= @questions.paginate(:per_page => 20)
    else
      @questions = Question.find(:all, :order => "created_at DESC").paginate(:per_page => 20)
      @title = t(:all_questions)
    end
    @new_question = Question.new

    @tags = Question.tag_counts.sort{|x, y| x.name.downcase <=> y.name.downcase }

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @questions }
    end
  end

  def show
    @question = Question.find(params[:id])
    @title = t(:question) + truncate(@question.title, :length => 50, :ommision => '...')

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @question }
    end
  end

  def new
    @question = Question.new
    @title = t(:new_question)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @question }
    end
  end

  def edit
    @question = Question.find(params[:id])
    @title = t(:edit_question)
  end

  def create
    @title = t(:new_question)
    @question = Question.new(params[:question])
    @question.user = try(:current_user)

    respond_to do |format|
      if @question.duplicate? or @question.save
        flash[:notice] = t(:question_created_successfully) 
        format.html { redirect_to(@question) }
        format.xml  { render :xml => @question, :status => :created, :location => @question }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @question.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @question = Question.find(params[:id])

    respond_to do |format|
      if @question.update_attributes(params[:question])
        flash[:notice] = 'Question was successfully updated.'
        format.html { redirect_to(@question) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @question.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @question = Question.find(params[:id])
    @question.destroy

    respond_to do |format|
      format.html { redirect_to(questions_url) }
      format.xml  { head :ok }
    end
  end

  def unanswered
    @questions = Question.find_by_sql("SELECT * FROM questions qu WHERE qu.id NOT IN ( SELECT DISTINCT question_id FROM answers) order by created_at DESC ").paginate(:per_page => 20)
   @title = t(:unanswered_questions)

   @tags = Question.tag_counts.sort{|x, y| x.name.downcase <=> y.name.downcase }

   respond_to do |format|
      format.html { render :action => "index" }
    end

  end
end
