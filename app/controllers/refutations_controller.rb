class RefutationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conjecture
  before_action :set_refutation, only: [ :destroy ]
  before_action :authorize_user, only: [ :destroy ]

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
end
