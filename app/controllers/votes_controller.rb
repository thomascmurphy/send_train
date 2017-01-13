class VotesController < ApplicationController

  def new
    if params[:voteable_type].present? && params[:voteable_id].present?
      klass = Object.const_get params[:voteable_type]
      voteable = klass.find(params[:voteable_id])
      if voteable.present?
        vote_value = params[:value].present? ? params[:value] : 1
        existing_vote = current_user.votes.where(voteable: voteable).first
        if existing_vote.present?
          if existing_vote.value == vote_value
            existing_vote.value = 0
          else
            existing_vote.value = vote_value
          end
          existing_vote.save
        else
          existing_vote = current_user.votes.create(voteable: voteable, value: vote_value)
        end
      end
    end

    @voted_object = voteable
    respond_to do |format|
      format.html
      format.js {render "votes/refresh"}
      format.json
    end
  end

end
