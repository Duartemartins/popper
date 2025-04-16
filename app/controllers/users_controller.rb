class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def show
    @accepted_refutations = @user.refutations.where(accepted: true)
    @conjectures = @user.conjectures
    @refutations = @user.refutations

    # Check for bounties pending wallet address for this user
    @pending_wallet_bounties = Bounty.joins(:refutation)
                                     .where(refutations: { user_id: @user.id }, pending_wallet: true)
  end

  def edit
  end

  def update
    # Check if wallet address is being added for the first time
    wallet_address_being_added = params[:user][:wallet_address].present? && @user.wallet_address.blank?
    user_has_pending_bounties = wallet_address_being_added && Bounty.joins(:refutation).where(refutations: { user_id: @user.id }, pending_wallet: true).exists?

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

      # Add admin notification if wallet was added and pending bounties exist
      if user_has_pending_bounties
        # TODO: Implement a more robust admin notification system (e.g., database record, email)
        flash[:admin_notice] = "User #{@user.display_name} (ID: #{@user.id}) added a wallet address. Bounties pending release may now be processed."
      end

      redirect_to profile_path, notice: "Profile updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def onboard_stripe
    # REMOVE STRIPE: No longer needed
    # onboarding_url = current_user.generate_stripe_onboarding_link(redirect_url: profile_url)
    # redirect_to onboarding_url, allow_other_host: true
    redirect_to profile_path, alert: "Stripe onboarding is no longer required."
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(
      :email, :password, :password_confirmation,
      :username, :title, :first_name, :last_name, :organization, :display_name_preference, :country, :wallet_address
    )
  end

  def needs_password?(user, params)
    params[:password].present?
  end
end
