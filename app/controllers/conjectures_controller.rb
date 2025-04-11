class ConjecturesController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_conjecture, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_user, only: [ :edit, :update, :destroy ]

  def index
    @conjectures = Conjecture.left_joins(:bounties)
                           .select("conjectures.*, COALESCE(SUM(bounties.amount), 0) as total_bounty_amount")
                           .group("conjectures.id")

    if params[:tag].present?
      @tag = Tag.find_by(name: params[:tag].downcase)
      @conjectures = @conjectures.joins(:tags).where(tags: { id: @tag }) if @tag
    end

    # Get all tags for the filter
    @tags = Tag.all.order(:name)

    # Order by bounty amount (highest first) then by creation date
    @conjectures = @conjectures.order("total_bounty_amount DESC, conjectures.created_at DESC")
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
    params.require(:conjecture).permit(:title, :description, :falsification_criteria, :status, :tag_list)
  end

  def authorize_user
    unless @conjecture.user == current_user
      redirect_to conjectures_path, alert: "You are not authorized to perform this action."
    end
  end
end
