class CommentsController < ApplicationController
  after_filter :discard_flash, only: :create

  def new

  end

  def create
    UserMailer.comment_email(params[:subject], params[:comment], params[:from_email]).deliver_now
    respond_to do |format|
      format.html {redirect_to root_path, notice: 'Thanks very much for your feedback!' }
      format.js { flash[:notice] = "Thanks very much for your feedback!" }
      format.json
    end
  end

  private

  def discard_flash
    flash.discard if request.xhr?
  end
end
