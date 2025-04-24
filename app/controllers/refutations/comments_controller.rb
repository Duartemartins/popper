class Refutations::CommentsController < ApplicationController
  before_action :set_refutation
  before_action :authenticate_user!

  def create
    @comment = @refutation.comments.new(comment_params)
    @comment.user = current_user
    @comment.parent_id = params[:parent_id] if params[:parent_id]
    if @comment.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @refutation, notice: 'Comment posted.' }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace('comment_form', partial: 'comments/form', locals: { commentable: @refutation, comment: @comment }) }
        format.html { redirect_to @refutation, alert: 'Failed to post comment.' }
      end
    end
  end

  def destroy
    @comment = @refutation.comments.find(params[:id])
    @comment.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @refutation, notice: 'Comment deleted.' }
    end
  end

  private
  def set_refutation
    @refutation = Refutation.find(params[:refutation_id])
  end

  def comment_params
    params.require(:comment).permit(:content, :parent_id)
  end
end
