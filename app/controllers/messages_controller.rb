class MessagesController < ApplicationController

  def index
    @messages = Message.where(parent_message_id: nil, messageable_id: nil).sort_by{|x| [Vote.item_score(x), x.updated_at]}.reverse
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @messages, status: :ok, location: @messages }
    end
  end

  def show
    @primary_message = Message.find_by_id(params[:id])
    if @primary_message.belongs_to_user(current_user) && @primary_message.read.blank?
      @primary_message.read = true
      @primary_message.save
    end

    respond_to do |format|
      format.html
      format.js
      format.json { render json: @primary_message, status: :ok, location: @primary_message }
    end
  end

  def new
    @message = Message.new()
    @message.user_id = current_user.id
    @primary_message_id = params[:primary_message_id]
    if params[:parent_message_id].present?
      @message.parent_message_id = params[:parent_message_id]
    end
    if params[:messageable_id].present? && params[:messageable_type].present?
      @message.messageable_id = params[:messageable_id]
      @message.messageable_type = params[:messageable_type]
    end
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @message, status: :created, location: @message }
    end
  end

  def create
    @message = Message.new(message_params)
    @message.user_id = current_user.id
    if params[:primary_message_id].present?
      @primary_message = Message.find_by_id(params[:primary_message_id])
    else
      @primary_message = @message
    end

    respond_to do |format|
      if @message.save
        @messages = Message.where(parent_message_id: nil, messageable_id: nil).sort_by{|x| [Vote.item_score(x), x.updated_at]}.reverse
        format.html { redirect_to @message, notice: 'Message was successfully created.' }
        format.js
        format.json { render json: @message, status: :created, location: @message }
      else
        format.html { render action: "new" }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @message = current_user.messages.find_by_id(params[:id])
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @message, status: :ok, location: @message }
    end
  end

  def update
    @message = current_user.messages.find_by_id(params[:id])

    respond_to do |format|
      if @message.update_attributes(message_params)
        format.html
        format.js
        format.json { render json: @message, status: :ok, location: @message }
      else
        format.html
        format.js
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  def delete
    @message = current_user.messages.find_by_id(params[:message_id])
    respond_to do |format|
      format.html
      format.js
      format.json
    end
  end

  def destroy
    @message = current_user.messages.find_by_id(params[:id])
    @message.destroy
  end

  private

  def message_params
    params.require(:message).permit(:title, :body, :parent_message_id, :messageable_id,
                                    :messageable_type, :read, :views)
  end
end
