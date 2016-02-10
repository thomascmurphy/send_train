class CommentsController < ApplicationController
  def new

  end

  def create
    UserMailer.comment_email(params[:subject], params[:comment], params[:from_email]).deliver_now
    respond_to do |format|
      format.html
      format.js
      format.json
    end
  end
end
