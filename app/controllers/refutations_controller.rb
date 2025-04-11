class RefutationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conjecture
  before_action :set_refutation, only: [ :destroy, :accept ]
  before_action :authorize_user, only: [ :destroy ]
  before_action :authorize_conjecture_owner, only: [ :accept ]

  def create
    @refutation = @conjecture.refutations.build(refutation_params)
    @refutation.user = current_user

    if @refutation.save
      redirect_to conjecture_path(@conjecture), notice: "Refutation was successfully added."
    else
      redirect_to conjecture_path(@conjecture), alert: "Failed to add refutation."
    end
  end

  def destroy
    @refutation.destroy
    redirect_to conjecture_path(@conjecture), notice: "Refutation was successfully deleted."
  end

  def accept
    ActiveRecord::Base.transaction do
      # Mark this refutation as accepted
      @refutation.update!(accepted: true)

      # Mark the conjecture as refuted
      @conjecture.update!(status: :refuted)

      # Award the bounty to the refutation author if there is any bounty
      if @conjecture.total_bounty > 0
        # Get all bounty amounts
        bounty_total = @conjecture.total_bounty

        # Record the payout in a more permanent way
        # You could create a Payout model for this in a real app
        # For now, we'll add a note to the refutation content
        payout_note = "\n\n[System] Bounty of $#{bounty_total} awarded to #{@refutation.user.email} on #{Time.now.strftime('%B %d, %Y')}"
        @refutation.update!(content: @refutation.content + payout_note)

        # In a real app, you might trigger an email notification here
        # or create a transaction record for the user who received the bounty
      end
    end

    redirect_to conjecture_path(@conjecture), notice: "Refutation accepted! The conjecture has been marked as refuted and any bounty has been awarded to #{@refutation.user.email}."
  end

  private

  def set_conjecture
    @conjecture = Conjecture.find(params[:conjecture_id])
  end

  def set_refutation
    @refutation = @conjecture.refutations.find(params[:id])
  end

  def refutation_params
    params.require(:refutation).permit(:content)
  end

  def authorize_user
    unless @refutation.user == current_user
      redirect_to conjecture_path(@conjecture), alert: "You are not authorized to perform this action."
    end
  end

  def authorize_conjecture_owner
    unless @conjecture.user == current_user
      redirect_to conjecture_path(@conjecture), alert: "Only the conjecture creator can accept refutations."
    end
  end
end
