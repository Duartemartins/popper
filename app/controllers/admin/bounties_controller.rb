class Admin::BountiesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_bounty, only: [:release]

  # Show all bounties in escrow (paid, not released)
  def escrow
    @bounties = Bounty.where(paid: true, released_at: nil).includes(:user, :conjecture)
  end

  # Release a bounty from escrow and send ETH payout
  def release
    # Only release if not already released
    if @bounty.released_at.present?
      Rails.logger.info("[BountyRelease] Attempted to release already released bounty id=#{@bounty.id}")
      redirect_to admin_bounties_escrow_path, alert: 'Bounty already released.' and return
    end

    # Determine the refutation owner
    refutation = @bounty.refutation
    if refutation.nil?
      Rails.logger.warn("[BountyRelease] Bounty id=#{@bounty.id} has no associated refutation.")
      redirect_to admin_bounties_escrow_path, alert: "Cannot release this bounty: It is not associated with a specific refutation." and return
    end

    recipient_user = refutation.user
    recipient_wallet = recipient_user.wallet_address
    amount = @bounty.amount.to_f

    if recipient_wallet.blank?
      Rails.logger.warn("[BountyRelease] Refutation owner user_id=#{recipient_user.id} has no wallet address.")
      @bounty.update!(pending_wallet: true)
      redirect_to admin_bounties_escrow_path, alert: "Refutation owner has not set a wallet address. They will be notified to add one to claim the bounty." and return
    end

    Rails.logger.info("[BountyRelease] Initiating payout for bounty id=#{@bounty.id} to user_id=#{recipient_user.id} wallet=#{recipient_wallet} amount=#{amount}")
    begin
      tx_hash = EthereumWallet.send_eth(recipient_wallet, amount)
      Rails.logger.info("[BountyRelease] Payout successful. Bounty id=#{@bounty.id} tx_hash=#{tx_hash}")
      @bounty.update!(released_at: Time.current, payout_tx_hash: tx_hash, pending_wallet: false)
      redirect_to admin_bounties_escrow_path, notice: 'Bounty released and payout sent!'
    rescue => e
      Rails.logger.error("[BountyRelease] Failed to release bounty id=#{@bounty.id}: #{e.message}")
      redirect_to admin_bounties_escrow_path, alert: "Failed to release bounty: #{e.message}"
    end
  end

  private
  def set_bounty
    @bounty = Bounty.find(params[:id])
  end

  def require_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: 'Admins only.'
    end
  end
end
