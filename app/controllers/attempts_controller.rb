class AttemptsController < ApplicationController

  def index

  end

  def show

  end

  def new
    @climb = current_user.climbs.find_by_id(params[:climb_id])
    @attempt = @climb.attempts.new
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @attempt, status: :created, location: @attempt }
    end
  end

  def create
    @climbs = current_user.climbs.order(created_at: :desc)
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

  end

  def update

  end

  def delete

  end

  def destroy

  end

  private
    def attempt_params
      params.require(:attempt).permit(:climb_id, :date, :completion, :flash, :onsight)
    end
end
