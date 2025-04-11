class ConjecturesController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_conjecture, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_user, only: [ :edit, :update, :destroy ]

  def index
    @conjectures = Conjecture.all.order(created_at: :desc)
  end

  def show
    @refutation = Refutation.new
    @bounty = Bounty.new
  end

  def new
    @conjecture = Conjecture.new
  end

  def create
    @conjecture = current_user.conjectures.build(conjecture_params)

    if @conjecture.save
      redirect_to @conjecture, notice: "Conjecture was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @conjecture.update(conjecture_params)
      redirect_to @conjecture, notice: "Conjecture was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @conjecture.destroy
    redirect_to conjectures_path, notice: "Conjecture was successfully deleted."
  end

  private

  def set_conjecture
    @conjecture = Conjecture.find(params[:id])
  end

  def conjecture_params
    params.require(:conjecture).permit(:title, :description, :falsification_criteria, :status)
  end

  def authorize_user
    unless @conjecture.user == current_user
      redirect_to conjectures_path, alert: "You are not authorized to perform this action."
    end
  end
end
