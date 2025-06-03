class Admin::BountiesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_bounty, only: [ :release ]

  # Show all bounties in escrow (paid, not released)
  def escrow
    @bounties = Bounty.where(paid: true, released_at: nil).includes(:user, :conjecture)
  end

  # Release a bounty from escrow and send ETH payout
  def release
    # Security: Enhanced admin confirmation parameter with timestamp validation
    expected_confirmation = "CONFIRM_PAYOUT_#{@bounty.id}_#{Time.current.to_i / 300}" # Valid for 5 minutes
    unless params[:admin_confirmation] == expected_confirmation
      Rails.logger.warn("[BountyRelease] Invalid confirmation from admin #{current_user.id} for bounty #{@bounty.id}")
      redirect_to admin_bounties_escrow_path, alert: "Invalid or expired confirmation. Please try again." and return
    end

    # Only release if not already released
    if @bounty.released_at.present?
      Rails.logger.info("[BountyRelease] Attempted to release already released bounty id=#{@bounty.id}")
      redirect_to admin_bounties_escrow_path, alert: "Bounty already released." and return
    end

    # Rate limiting: Check for recent releases by this admin
    recent_releases = Bounty.where(released_at: 5.minutes.ago..Time.current)
                           .where("payout_tx_hash IS NOT NULL")
                           .count

    if recent_releases >= 3
      Rails.logger.warn("[BountyRelease] Rate limit exceeded for admin #{current_user.id}")
      redirect_to admin_bounties_escrow_path, alert: "Too many recent releases. Please wait before releasing more bounties." and return
    end

    # Security: Additional verification that the bounty was properly funded
    unless @bounty.paid? && @bounty.processed_transaction.present?
      Rails.logger.warn("[BountyRelease] Attempted to release unfunded bounty id=#{@bounty.id}")
      redirect_to admin_bounties_escrow_path, alert: "Cannot release bounty: no verified funding transaction found." and return
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

    # Enhanced wallet validation
    unless recipient_wallet.present? && recipient_wallet.match?(/\A0x[a-fA-F0-9]{40}\z/)
      Rails.logger.warn("[BountyRelease] Refutation owner user_id=#{recipient_user.id} has invalid wallet address: #{recipient_wallet}")
      @bounty.update!(pending_wallet: true)
      redirect_to admin_bounties_escrow_path, alert: "Recipient has an invalid wallet address. They need to provide a valid Ethereum address." and return
    end

    # Amount validation
    if amount <= 0 || amount > 10 # Reasonable maximum
      Rails.logger.warn("[BountyRelease] Suspicious amount for bounty id=#{@bounty.id}: #{amount}")
      redirect_to admin_bounties_escrow_path, alert: "Invalid bounty amount: #{amount} ETH" and return
    end

    Rails.logger.info("[BountyRelease] Admin #{current_user.id} initiating payout for bounty id=#{@bounty.id} to user_id=#{recipient_user.id} wallet=#{recipient_wallet} amount=#{amount}")
    begin
      tx_hash = EthereumWallet.send_eth(recipient_wallet, amount)
      Rails.logger.info("[BountyRelease] Payout successful. Bounty id=#{@bounty.id} tx_hash=#{tx_hash}")
      @bounty.update!(released_at: Time.current, payout_tx_hash: tx_hash, pending_wallet: false)
      redirect_to admin_bounties_escrow_path, notice: "Bounty released and payout sent!"
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
      redirect_to root_path, alert: "Admins only."
    end
  end
end
