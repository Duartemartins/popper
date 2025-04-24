class Conjectures::CommentsController < ApplicationController
  before_action :set_conjecture
  before_action :authenticate_user!

  def create
    @comment = @conjecture.comments.new(comment_params)
    @comment.user = current_user
    @comment.parent_id = params[:parent_id] if params[:parent_id]
    if @comment.save
      redirect_to @conjecture, notice: 'Comment posted.'
    else
      redirect_to @conjecture, alert: 'Failed to post comment.'
    end
  end

  def destroy
    @comment = @conjecture.comments.find(params[:id])
    @comment.destroy
    redirect_to @conjecture, notice: 'Comment deleted.'
  end

  private
  def set_conjecture
    @conjecture = Conjecture.find(params[:conjecture_id])
  end

  def comment_params
    params.require(:comment).permit(:content, :parent_id)
  end
end
