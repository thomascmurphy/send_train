class ClimbsController < ApplicationController

  def index
    if user_signed_in?
      @climbs = current_user.climbs.order(created_at: :desc)
      attempts = current_user.attempts
      @first_attempt = attempts.order(date: :asc).first()
      @last_attempt = attempts.order(date: :desc).first()
      if @first_attempt.present?
        @date_lower = @first_attempt.date
      end
      if @last_attempt.present?
        @date_upper = @last_attempt.date
      end

      if params[:climb_type].present?
        @climbs = @climbs.where(climb_type: params[:climb_type])
      end

      date = params[:date]
      if date.present?
        if date[:day_lower].present? && date[:month_lower].present? && date[:year_lower].present?
          lower_date = DateTime.strptime("#{date[:year_lower]} #{date[:month_lower]} #{date[:day_lower]}", "%Y %m %d")
          lower_attempt_climb_ids = attempts.where("date > ?", lower_date).pluck(:climb_id).compact.uniq
        end

        if date[:day_upper].present? && date[:month_upper].present? && date[:year_upper].present?
          upper_date = DateTime.strptime("#{date[:year_upper]} #{date[:month_upper]} #{date[:day_upper]}", "%Y %m %d").end_of_day
          upper_attempt_climb_ids = attempts.where("date < ?", upper_date).pluck(:climb_id).compact.uniq
        end
        @climbs = @climbs.where(id: lower_attempt_climb_ids && upper_attempt_climb_ids)
      end

      @climbs = @climbs.sort_by{|c| [c.redpointed ? 0 : 1, c.redpoint_date]}.reverse
      respond_to do |format|
        format.html
        format.js { render :reload }
        format.json { render json: @climbs, status: :ok, location: @climb }
      end
    else
      redirect_to root_path
    end
  end

  def show
    if user_signed_in?
      @climb = current_user.climbs.find_by_id(params[:id])
      respond_to do |format|
        format.html
        format.js
        format.json { render json: @climb, status: :ok, location: @climb }
      end
    end
  end

  def new
    if user_signed_in?
      @boulder_grades = Climb.bouldering_grades
      @sport_grades = Climb.sport_grades
      @climb = current_user.climbs.new
      respond_to do |format|
        format.html
        format.js
        format.json { render json: @climb, status: :created, location: @climb }
      end
    end
  end

  def create
    if user_signed_in?
      @climbs = current_user.climbs.order(created_at: :desc)
      @climb = current_user.climbs.new(climb_params)

      respond_to do |format|
        if @climb.save
          format.html { redirect_to @climb, notice: 'Climb was successfully created.' }
          format.js
          format.json { render json: @climb, status: :created, location: @climb }
        else
          format.html { render action: "new" }
          format.json { render json: @climb.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def edit
    if user_signed_in?
      @boulder_grades = Climb.bouldering_grades
      @sport_grades = Climb.sport_grades
      @climb = current_user.climbs.find_by_id(params[:id])
      respond_to do |format|
        format.html
        format.js
        format.json { render json: @climb, status: :ok, location: @climb }
      end
    end
  end

  def update
    if user_signed_in?
      @climbs = current_user.climbs.order(created_at: :desc)
      @climb = current_user.climbs.find_by_id(params[:id])
      respond_to do |format|
        if @climb.update_attributes(climb_params)
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
  end

  def delete
    if user_signed_in?
      @climb = current_user.climbs.find_by_id(params[:climb_id])
      respond_to do |format|
        format.html
        format.js
        format.json
      end
    end
  end

  def destroy
    if user_signed_in?
      @climbs = current_user.climbs.order(created_at: :desc)
      @climb = current_user.climbs.find_by_id(params[:id])
      @climb.destroy
    end
  end

  private
    def climb_params
      params.require(:climb).permit(:name, :location, :climb_type, :grade, :length,
                                    :length_unit, :outdoor, :crimpy, :slopey, :pinchy,
                                    :pockety, :powerful, :endurance, :technical, :notes)
    end
end
