class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def index
    @eth_balance = EthereumWallet.balance
    @pending_bounties = Bounty.where(paid: false).includes(:user, :conjecture)
    @escrowed_bounties = Bounty.where(paid: true, released_at: nil).includes(:user, :conjecture)
  end

  private

  def require_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end
end
