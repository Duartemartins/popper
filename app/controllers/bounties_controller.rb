class BountiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conjecture

  def create
    @bounty = @conjecture.bounties.build(bounty_params)
    @bounty.user = current_user

    if @bounty.save
      redirect_to @conjecture, notice: "Bounty was successfully added."
    else
      redirect_to @conjecture, alert: "Failed to add bounty. #{@bounty.errors.full_messages.to_sentence}"
    end
  end

  private

  def set_conjecture
    @conjecture = Conjecture.find(params[:conjecture_id])
  end

  def bounty_params
    params.require(:bounty).permit(:amount)
  end
end
