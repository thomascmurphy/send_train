class AttemptsController < ApplicationController

  def index
    if user_signed_in?

    else
      redirect_to root_path
    end
  end

  def show
    if user_signed_in?

    end
  end

  def new
    if user_signed_in?
      @climb = current_user.climbs.find_by_id(params[:climb_id])
      @attempt = @climb.attempts.new
      respond_to do |format|
        format.html
        format.js
        format.json { render json: @attempt, status: :created, location: @attempt }
      end
    end
  end

  def create
    if user_signed_in?
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
  end

  def edit
    if user_signed_in?

    end
  end

  def update
    if user_signed_in?

    end
  end

  def delete
    if user_signed_in?

    end
  end

  def destroy
    if user_signed_in?

    end
  end

  private
    def attempt_params
      params.require(:attempt).permit(:climb_id, :date, :completion, :flash, :onsight)
    end
end
