class ClimbsController < ApplicationController
  helper_method :sort_by, :sort_direction, :page, :per_page, :ordered_climbs

  def index
    @climbs = ordered_climbs

    respond_to do |format|
      format.html
      format.js { render :reload }
      format.json { render json: @climbs, status: :ok, location: @climb }
    end
  end

  def show
    @climb = current_user.climbs.find_by_id(params[:id])
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @climb, status: :ok, location: @climb }
    end
  end

  def new
    @boulder_grades = Climb.bouldering_grades(current_user.grade_format)
    @sport_grades = Climb.sport_grades(current_user.grade_format)
    @climb = current_user.climbs.new
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @climb, status: :created, location: @climb }
    end
  end

  def create
    @climbs = current_user.climbs.order(created_at: :desc)
    @climb = current_user.climbs.new(climb_params)
    attempt_params = {}
    if params[:date].present?
      date = params[:date][:redpoint_date]
      if date.present?
        if date[:day].present? && date[:month].present? && date[:year].present?
          redpoint_date = DateTime.strptime("#{date[:year]} #{date[:month]} #{date[:day]}", "%Y %m %d")
          attempt_params[:date] = redpoint_date
          attempt_params[:onsight] = params[:onsight]
          attempt_params[:flash] = params[:flash]
          attempt_params[:completion] = 100
        end
      end
    end

    respond_to do |format|
      if @climb.save
        if attempt_params.present?
          attempt = @climb.attempts.create(attempt_params)
        end
        @climbs = @climbs.sort_by{|c| [c.redpointed ? 0 : 1, c.redpoint_date]}.reverse
        format.html { redirect_to @climb, notice: 'Climb was successfully created.' }
        format.js
        format.json { render json: @climb, status: :created, location: @climb }
      else
        format.html { render action: "new" }
        format.json { render json: @climb.errors, status: :unprocessable_entity }
      end
    end
  end

  def quick_new
    @boulder_grades = Climb.bouldering_grades(current_user.grade_format)
    @sport_grades = Climb.sport_grades(current_user.grade_format)
    @climb = current_user.climbs.new
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @climb, status: :created, location: @climb }
    end
  end

  def quick_create
    @climbs = current_user.climbs.order(created_at: :desc)
    @climb = current_user.climbs.new(climb_params)
    @climb.name = "Gym Climb"
    @climb.outdoor = false
    @climb.location = current_user.gym_name
    onsight = params[:onsight].present?
    flash = params[:flash].present?

    respond_to do |format|
      if @climb.save
        attempt = @climb.attempts.create(completion: 100, date: DateTime.now, onsight: onsight, flash: flash)
        @climbs = @climbs.sort_by{|c| [c.redpointed ? 0 : 1, c.redpoint_date]}.reverse
        format.html { redirect_to @climb, notice: 'Climb was successfully created.' }
        format.js
        format.json { render json: @climb, status: :created, location: @climb }
      else
        format.html { render action: "new" }
        format.json { render json: @climb.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @boulder_grades = Climb.bouldering_grades(current_user.grade_format)
    @sport_grades = Climb.sport_grades(current_user.grade_format)
    @climb = current_user.climbs.find_by_id(params[:id])
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @climb, status: :ok, location: @climb }
    end
  end

  def update
    @climbs = ordered_climbs
    @climb = current_user.climbs.find_by_id(params[:id])
    respond_to do |format|
      if @climb.update_attributes(climb_params)
        @climbs = @climbs.sort_by{|c| [c.redpointed ? 0 : 1, c.redpoint_date]}.reverse
        format.html
        format.js
        format.json { render json: @climb, status: :ok, location: @climb }
      else
        format.html
        format.js
        format.json { render json: @climb.errors, status: :unprocessable_entity }
      end
    end
  end

  def delete
    @climb = current_user.climbs.find_by_id(params[:climb_id])
    respond_to do |format|
      format.html
      format.js
      format.json
    end
  end

  def destroy
    @climb = current_user.climbs.find_by_id(params[:id])
    @climb.destroy
    @climbs = ordered_climbs
  end


  def sync_mountain_project
    respond_to do |format|
      if current_user.sync_mountain_project_climbs
        format.html { redirect_to climbs_path, notice: 'Sync complete!' }
        format.js
        format.json { render json: current_user.climbs, status: :ok, location: current_user.climbs }
      else
        format.html { redirect_to climbs_path, notice: 'Something went wrong with the sync :(' }
        format.js
        format.json { render json: nil, status: :unprocessable_entity }
      end
    end
  end

  private
    def climb_params
      params.require(:climb).permit(:name, :location, :climb_type, :grade, :length,
                                    :length_unit, :outdoor, :crimpy, :slopey, :pinchy,
                                    :pockety, :powerful, :dynamic, :endurance, :technical, :notes)
    end

    def sort_by
      legal_sorts = Climb.column_names + ['redpoint_date']
      legal_sorts.include?(params[:sort_by]) ? params[:sort_by] : "redpoint_date"
    end

    def sort_direction
      %w[asc desc].include?(params[:sort_direction]) ? params[:sort_direction] : "desc"
    end

    def page
      (params[:page] || 1).to_i
    end

    def per_page
      (params[:per_page] || 20).to_i
    end

    def ordered_climbs
      if sort_by == "redpoint_date"
        require 'will_paginate/array'
        climbs = current_user.climbs.sort_by{|c| [c.redpointed ? 0 : 1, c.redpoint_date, c.created_at]}
        if sort_direction.downcase == "desc"
          climbs = climbs.reverse
        end
      else
        climbs = current_user.climbs.order("#{sort_by} #{sort_direction}", "id ASC")
      end

      if params[:climb_type].present?
        climbs = climbs.where(climb_type: params[:climb_type])
      end

      if params[:outdoor].present?
        climbs = climbs.where(outdoor: params[:outdoor] == "true")
      end

      #@climbs = @climbs.sort_by{|c| [c.redpointed ? 0 : 1, c.redpoint_date, c.created_at]}.reverse

      climbs = climbs.paginate(:page => page, :per_page => per_page)
      climbs
    end
end
