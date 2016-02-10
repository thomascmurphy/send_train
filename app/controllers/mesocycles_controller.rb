class MesocyclesController < ApplicationController

  def index
    @mesocycles = current_user.mesocycles.order(created_at: :desc)
    if params[:mesocycle_type].present?
      @mesocycles = @mesocycles.where(mesocycle_type: params[:mesocycle_type])
    end

    respond_to do |format|
      format.html
      format.js { render :reload }
      format.json { render json: @mesocycles, status: :ok, location: @mesocycles }
    end
  end

  def show
    @mesocycle = current_user.mesocycles.find_by_id(params[:id])
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @mesocycle, status: :ok, location: @mesocycle }
    end
  end

  def new
    @microcycles = current_user.microcycles.order(created_at: :desc)
    @mesocycle = current_user.mesocycles.new
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @mesocycle, status: :created, location: @mesocycle }
    end
  end

  def create
    @mesocycles = current_user.mesocycles.order(created_at: :desc)
    if params[:mesocycle][:microcycle_ids].present?
      params[:mesocycle][:microcycle_ids] = params[:mesocycle][:microcycle_ids].strip().split(' ')
    end
    @mesocycle = current_user.mesocycles.new(mesocycle_params)

    respond_to do |format|
      if @mesocycle.save
        format.html { redirect_to @mesocycle, notice: 'Mesocycle was successfully created.' }
        format.js
        format.json { render json: @mesocycle, status: :created, location: @mesocycle }
      else
        format.html { render action: "new" }
        format.json { render json: @mesocycle.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @microcycles = current_user.microcycles.order(created_at: :desc)
    @mesocycle = current_user.mesocycles.find_by_id(params[:id])
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @mesocycle, status: :ok, location: @mesocycle }
    end
  end

  def update
    @mesocycles = current_user.mesocycles.order(created_at: :desc)
    if params[:mesocycle][:microcycle_ids].present?
      params[:mesocycle][:microcycle_ids] = params[:mesocycle][:microcycle_ids].strip().split(' ')
    end
    @mesocycle = current_user.mesocycles.find_by_id(params[:id])
    respond_to do |format|
      if @mesocycle.update_attributes(mesocycle_params)
        format.html
        format.js
        format.json { render json: @mesocycle, status: :ok, location: @mesocycle }
      else
        format.html
        format.js
        format.json { render json: @mesocycle.errors, status: :unprocessable_entity }
      end
    end
  end

  def delete
    @mesocycle = current_user.mesocycles.find_by_id(params[:mesocycle_id])
    respond_to do |format|
      format.html
      format.js
      format.json
    end
  end

  def destroy
    @mesocycles = current_user.mesocycles.order(created_at: :desc)
    @mesocycle = current_user.mesocycles.find_by_id(params[:id])
    @mesocycle.destroy
  end


  private
    def mesocycle_params
      params.require(:mesocycle).permit(:label, :mesocycle_type, :microcycle_ids => [])
    end

end
