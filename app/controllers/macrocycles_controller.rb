class MacrocyclesController < ApplicationController

  def index
    if user_signed_in?
      @macrocycles = current_user.macrocycles.order(created_at: :desc)

      if params[:macrocycle_type].present?
        @macrocycles = @macrocycles.where(macrocycle_type: params[:macrocycle_type])
      end

      respond_to do |format|
        format.html
        format.js { render :reload }
        format.json { render json: @macrocycles, status: :ok, location: @macrocycles }
      end
    else
      redirect_to root_path
    end
  end

  def show
    if user_signed_in?
      @macrocycle = current_user.macrocycles.find_by_id(params[:id])
      respond_to do |format|
        format.html
        format.js
        format.json { render json: @macrocycle, status: :ok, location: @macrocycle }
      end
    end
  end

  def new
    if user_signed_in?
      @mesocycles = current_user.mesocycles.order(created_at: :desc)
      @macrocycle = current_user.macrocycles.new
      respond_to do |format|
        format.html
        format.js
        format.json { render json: @macrocycle, status: :created, location: @macrocycle }
      end
    end
  end

  def create
    if user_signed_in?
      @macrocycles = current_user.macrocycles.order(created_at: :desc)
      if params[:macrocycle][:mesocycle_ids].present?
        params[:macrocycle][:mesocycle_ids] = params[:macrocycle][:mesocycle_ids].strip().split(' ')
      end
      @macrocycle = current_user.macrocycles.new(macrocycle_params)

      respond_to do |format|
        if @macrocycle.save
          format.html { redirect_to @macrocycle, notice: 'Macrocycle was successfully created.' }
          format.js
          format.json { render json: @macrocycle, status: :created, location: @macrocycle }
        else
          format.html { render action: "new" }
          format.json { render json: @macrocycle.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def edit
    if user_signed_in?
      @mesocycles = current_user.mesocycles.order(created_at: :desc)
      @macrocycle = current_user.macrocycles.find_by_id(params[:id])
      respond_to do |format|
        format.html
        format.js
        format.json { render json: @macrocycle, status: :ok, location: @macrocycle }
      end
    end
  end

  def update
    if user_signed_in?
      @macrocycles = current_user.macrocycles.order(created_at: :desc)
      if params[:macrocycle][:mesocycle_ids].present?
        params[:macrocycle][:mesocycle_ids] = params[:macrocycle][:mesocycle_ids].strip().split(' ')
      end
      @macrocycle = current_user.macrocycles.find_by_id(params[:id])
      respond_to do |format|
        if @macrocycle.update_attributes(macrocycle_params)
          format.html
          format.js
          format.json { render json: @macrocycle, status: :ok, location: @macrocycle }
        else
          format.html
          format.js
          format.json { render json: @macrocycle.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def delete
    if user_signed_in?
      @macrocycle = current_user.macrocycles.find_by_id(params[:macrocycle_id])
      respond_to do |format|
        format.html
        format.js
        format.json
      end
    end
  end

  def destroy
    if user_signed_in?
      @macrocycles = current_user.macrocycles.order(created_at: :desc)
      @macrocycle = current_user.macrocycles.find_by_id(params[:id])
      @macrocycle.destroy
    end
  end


  private
    def macrocycle_params
      params.require(:macrocycle).permit(:label, :macrocycle_type, :mesocycle_ids => [])
    end

end
