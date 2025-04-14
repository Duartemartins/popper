class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def show
    @accepted_refutations = @user.refutations.where(accepted: true)
    @conjectures = @user.conjectures
    @refutations = @user.refutations
  end

  def edit
  end

  def update
    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    successfully_updated = if needs_password?(@user, params[:user])
                           @user.update(user_params)
    else
                           @user.update_without_password(user_params)
    end

    if successfully_updated
      # Sign in the user bypassing validation in case their password changed
      bypass_sign_in(@user)
      redirect_to profile_path, notice: "Profile updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def claim_bounty
    # Logic for claiming bounty would go here
    # For now, we'll just redirect with a notice
    redirect_to profile_path, notice: "Bounty claiming feature is coming soon!"
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(
      :email, :password, :password_confirmation,
      :username, :title, :first_name, :last_name, :organization, :display_name_preference
    )
  end

  def needs_password?(user, params)
    params[:password].present?
  end
end
