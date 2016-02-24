class ItemSharesController < ApplicationController

  def show
    @boulder_grades = Climb.bouldering_grades(current_user.grade_format)
    @sport_grades = Climb.sport_grades(current_user.grade_format)
    @item_share = ItemShare.where(id: params[:id], recipient_id: current_user.id).first
    if @item_share.present?
      @item_share.received = true
      @item_share.save
    else
      redirect_to root_path, notice: "That item does not exist"
    end
  end

  def new
    @item_share = ItemShare.new(sharer_id: current_user.id,
                                item_type: params[:item_type],
                                item_id: params[:item_id])
    respond_to do |format|
      format.html
      format.js
      format.json
    end
  end

  def create
    recipient = User.find_by_email(params[:email])
    @item_share = ItemShare.new(item_share_params)
    @item_share.sharer_id = current_user.id
    if recipient.present? && recipient.accept_shares?
      @item_share.recipient_id = recipient.id
      respond_to do |format|
        if @item_share.save
          format.html
          format.js
          format.json { render json: @item_share, status: :ok, location: @item_share }
        else
          format.html
          format.js
          format.json { render json: @item_share.errors, status: :unprocessable_entity }
        end
      end
    else
      @item_share.errors.add(:recipient_id, "There is either no user associated with that email or they have sharing disabled.")
      respond_to do |format|
        format.html
        format.js
        format.json { render json: @item_share.errors, status: :unprocessable_entity }
      end
    end

  end

  def accept
    @item_share = ItemShare.where(id: params[:item_share_id], recipient_id: current_user.id).first
    if @item_share.present?
      new_item = @item_share.item.duplicate(current_user)
      @item_share.accepted = true
      @item_share.save
      redirect_to new_item, notice: "Item successfully copied!"
    else
      redirect_to root_path, notice: "That item does not exist"
    end
  end

  def reject
    @item_share = ItemShare.where(id: params[:item_share_id], recipient_id: current_user.id).first
    if @item_share.present?
      @item_share.accepted = false
      @item_share.save
    else
      redirect_to root_path, notice: "That item does not exist"
    end
  end

  private

  def item_share_params
    params.require(:item_share).permit(:item_type, :item_id, :notes)
  end

end
