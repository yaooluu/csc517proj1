class StoriesController < ApplicationController
  include SessionsHelper

  # GET /stories
  # GET /stories.json
  def index
    if logged_in?
      @user = current_user

      if params[:keyword]
        @stories = Story.search(params[:keyword])
      elsif admin?
        @stories = Story.all
      elsif
        @stories = Story.where("project_id = '#{@user.project_id}'")
      end

      if @user.project_id
        @project = Project.find(@user.project_id)
      end

    else
      @stories = []
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @stories }
    end
  end

  # GET /stories/1
  # GET /stories/1.json
  def show
    @story = Story.find(params[:id])
    @users = User.where("story_id = '#{@story.id}'")

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @story }
    end
  end

  # GET /stories/new
  # GET /stories/new.json
  def new
    @story = Story.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @story }
    end
  end

  # GET /stories/1/edit
  def edit
    @story = Story.find(params[:id])
  end

  # POST /stories
  # POST /stories.json
  def create
    @story = Story.new(story_params)

    #set story's foreign key: project_id
    @user = current_user
    @project = Project.find(@user.project_id)
    @story.project_id = @project.id

    respond_to do |format|
      if @story.save
        format.html { redirect_to stories_path, notice: 'Story was successfully created.' }
        format.json { render json: @story, status: :created, location: @story }
      else
        format.html { render action: "new" }
        format.json { render json: @story.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /stories/1
  # PUT /stories/1.json
  def update
    @story = Story.find(params[:id])

    respond_to do |format|
      if @story.update(story_params)
        format.html { redirect_to stories_path, notice: 'Story ' + @story.title + ' was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @story.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stories/1
  # DELETE /stories/1.json
  def destroy
    @story = Story.find(params[:id])
    @story.destroy

    respond_to do |format|
      format.html { redirect_to stories_path, notice: 'Story ' + @story.title + ' was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def sign
    @story = Story.find(params[:id])
    @user = current_user


    logger.info "Number of devs #{@user.number_of_devs_in_story(params)}"

    # if story has 2 developers, unsign one
    if @user.number_of_devs_in_story(params) > 1
      @user_remove = User.where(:story_id => params[:id]).first
      @user_remove.update_attributes!(:story_id => nil)
    end

    # add story id to current user
    @user.update_attributes!(:story_id => @story.id)


    respond_to do |format|
      format.html { redirect_to stories_path, notice: 'Story was successfully signed or switched.' }
      format.json { head :no_content }
    end
  end

  def search
    puts 'In search method!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    @stories = Story.search(params[:keyword])
  end

  def story_params
    params.require(:story).permit(:title, :description, :pointVal, :stage)
  end


end
