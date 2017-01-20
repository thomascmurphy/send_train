class MessagesController < ApplicationController
  helper_method :page, :per_page

  def index
    require 'will_paginate/array'
    @messages = Message.where(parent_message_id: nil, messageable_id: nil).sort_by{|x| [Vote.item_score(x), x.updated_at]}.reverse
    @messages = @messages.paginate(:page => page, :per_page => per_page)
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
        require 'will_paginate/array'
        @messages = Message.where(parent_message_id: nil, messageable_id: nil).sort_by{|x| [Vote.item_score(x), x.updated_at]}.reverse
        @messages = @messages.paginate(:page => page, :per_page => per_page)
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
    @message = current_user.sent_messages.find_by_id(params[:id])
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @message, status: :ok, location: @message }
    end
  end

  def update
    @message = current_user.sent_messages.find_by_id(params[:id])
    if params[:primary_message_id].present?
      @primary_message = Message.find_by_id(params[:primary_message_id])
    else
      @primary_message = @message
    end
    respond_to do |format|
      if @message.update_attributes(message_params)
        require 'will_paginate/array'
        @messages = Message.where(parent_message_id: nil, messageable_id: nil).sort_by{|x| [Vote.item_score(x), x.updated_at]}.reverse
        @messages = @messages.paginate(:page => page, :per_page => per_page)
        format.html { redirect_to @message, notice: 'Message was successfully updated.' }
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
    @message = current_user.sent_messages.find_by_id(params[:message_id])
    if params[:primary_message_id].present?
      @primary_message = Message.find_by_id(params[:primary_message_id])
    else
      @primary_message = @message
    end
    respond_to do |format|
      format.html
      format.js
      format.json
    end
  end

  def destroy
    @message = current_user.sent_messages.find_by_id(params[:id])
    @message.deleted = true
    if params[:primary_message_id].present?
      @primary_message = Message.find_by_id(params[:primary_message_id])
    else
      @primary_message = @message
    end
    respond_to do |format|
      if @message.save
        require 'will_paginate/array'
        @messages = Message.where(parent_message_id: nil, messageable_id: nil).sort_by{|x| [Vote.item_score(x), x.updated_at]}.reverse
        @messages = @messages.paginate(:page => page, :per_page => per_page)
        format.html { redirect_to @message, notice: 'Message was successfully deleted.' }
        format.js
        format.json { render json: @message, status: :created, location: @message }
      else
        format.html { render action: "new" }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  def inbox_unread
    require 'will_paginate/array'
    @new_messages = current_user.new_messages
    @new_messages = @new_messages.paginate(:page => page, :per_page => per_page)
  end

  def inbox
    require 'will_paginate/array'
    @all_messages = current_user.all_messages
    @all_messages = @all_messages.paginate(:page => page, :per_page => per_page)
  end

  private

  def message_params
    params.require(:message).permit(:title, :body, :parent_message_id, :messageable_id,
                                    :messageable_type, :read, :views, :deleted)
  end

  def page
    (params[:page] || 1).to_i
  end

  def per_page
    (params[:per_page] || 20).to_i
  end
end
