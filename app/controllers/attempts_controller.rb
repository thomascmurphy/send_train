class AttemptsController < ApplicationController
  helper_method :sort_by, :sort_direction, :page, :per_page

  def set_other_models
    @boulder_grades = Climb.bouldering_grades(current_user.grade_format)
    @sport_grades = Climb.sport_grades(current_user.grade_format)
    @climbs = current_user.climbs.order(created_at: :desc)
    @climbs = @climbs.sort_by{|c| [c.redpointed ? 0 : 1, c.redpoint_date]}.reverse
  end

  def index

  end

  def show

  end

  def new
    @climb = current_user.climbs.find_by_id(params[:climb_id])
    @attempt = @climb.attempts.new
    @attempt.set_date_to_now
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @attempt, status: :created, location: @attempt }
    end
  end

  def create
    @climb = current_user.climbs.find_by_id(params[:climb_id])
    date = params[:date]
    if date.present?
      if date[:day].present? && date[:month].present? && date[:year].present?
        attempt_date = DateTime.strptime("#{date[:year]} #{date[:month]} #{date[:day]}", "%Y %m %d")
        params[:attempt][:date] = attempt_date
      end
    end
    @attempt = @climb.attempts.new(attempt_params)

    respond_to do |format|
      if @attempt.save
        self.set_other_models()
        format.html { redirect_to @attempt, notice: 'Attempt was successfully created.' }
        format.js
        format.json { render json: @attempt, status: :created, location: @attempt }
      else
        format.html { render action: "new" }
        format.json { render json: @attempt.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @attempt = current_user.attempts.find_by_id(params[:id])
    @climb = @attempt.climb
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @attempt, status: :ok, location: @attempt }
    end
  end

  def update
    @attempt = current_user.attempts.find_by_id(params[:id])
    @climb = @attempt.climb
    date = params[:date]
    if date.present?
      if date[:day].present? && date[:month].present? && date[:year].present?
        attempt_date = DateTime.strptime("#{date[:year]} #{date[:month]} #{date[:day]}", "%Y %m %d")
        params[:attempt][:date] = attempt_date
      end
    end

    respond_to do |format|
      if @attempt.update_attributes(attempt_params)
        self.set_other_models()
        format.html { redirect_to @attempt, notice: 'Attempt was successfully updated.' }
        format.js
        format.json { render json: @attempt, status: :created, location: @attempt }
      else
        format.html { render action: "update" }
        format.json { render json: @attempt.errors, status: :unprocessable_entity }
      end
    end
  end

  def delete

  end

  def destroy
    @attempt = current_user.attempts.find_by_id(params[:id])
    @climb = @attempt.climb
    @attempt.destroy
    self.set_other_models()
  end

  private
    def attempt_params
      params.require(:attempt).permit(:climb_id, :date, :completion, :flash, :onsight)
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
end
