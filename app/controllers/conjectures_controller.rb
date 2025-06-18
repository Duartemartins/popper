class ConjecturesController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_conjecture, only: [ :show, :edit, :update, :destroy, :add_bounty_verification ]
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
    if @conjecture.ai_feedback.blank?
      OpenaiFeedbackJob.perform_later(@conjecture.id)
      @ai_feedback = nil
      @ai_feedback_generating = true
    else
      @ai_feedback = @conjecture.ai_feedback
      @ai_feedback_generating = false
    end
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
    if @conjecture.refuted?
      redirect_to @conjecture, alert: "You cannot delete a conjecture that has been refuted."
      return
    end
    if @conjecture.refutations.where(accepted: true).exists?
      redirect_to @conjecture, alert: "You cannot delete a conjecture with an accepted refutation."
      return
    end
    @conjecture.destroy
    respond_to do |format|
      format.html { redirect_to conjectures_url, notice: "Conjecture was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # POST /conjectures/:id/add_bounty_verification
  def add_bounty_verification
    Rails.logger.info "[BountyVerification] Params received: #{params.inspect}"
    tx_hash = params[:tx_hash] || (request.content_type == "application/json" && params[:tx_hash])
    amount = params[:amount].to_f
    Rails.logger.info "[BountyVerification] tx_hash: #{tx_hash}, amount: #{amount}"

    unless tx_hash.present? && amount > 0
      Rails.logger.warn "[BountyVerification] Missing transaction hash or amount."
      render json: { success: false, error: "Missing transaction hash or amount." }, status: :unprocessable_entity and return
    end

    # Security: Check for transaction replay attacks
    if ProcessedTransaction.exists?(tx_hash: tx_hash)
      Rails.logger.warn "[BountyVerification] Transaction #{tx_hash} already processed - replay attack attempt"
      render json: { success: false, error: "Transaction already processed." }, status: :unprocessable_entity and return
    end

    # Security: Rate limiting per user
    recent_transactions = ProcessedTransaction.for_user(current_user).recent.count
    if recent_transactions >= 5
      Rails.logger.warn "[BountyVerification] Rate limit exceeded for user #{current_user.id}"
      render json: { success: false, error: "Too many recent transactions. Please wait before submitting again." }, status: :too_many_requests and return
    end

    begin
      tx = EthereumWallet.get_transaction(tx_hash)
      Rails.logger.info "[BountyVerification] EthereumWallet.get_transaction returned: #{tx.inspect}"
      if tx.nil?
        Rails.logger.warn "[BountyVerification] Transaction not found on-chain."
        render json: { success: false, error: "Transaction not found on-chain. Please wait for confirmation and try again." }, status: :unprocessable_entity and return
      end

      platform_wallet = Rails.application.credentials.dig(Rails.env.to_sym, :ethereum, :address) || ENV["PLATFORM_WALLET_ADDRESS"]
      Rails.logger.info "[BountyVerification] platform_wallet: #{platform_wallet}, tx['to']: #{tx['to']}, tx['value']: #{tx['value']}, tx['confirmations']: #{tx['confirmations']}"

      # Convert amount (Ether) to Wei for accurate comparison
      required_value_wei = (amount * 1e18).to_i
      actual_value_wei = tx["value"].to_i(16) # Convert hex string to integer
      Rails.logger.info "[BountyVerification] Comparing Wei: actual=#{actual_value_wei}, required=#{required_value_wei}"

      # Enhanced security checks
      min_confirmations = Rails.env.production? ? 3 : 1

      # Validate transaction requirements with enhanced security
      valid_recipient = tx["to"]&.downcase == platform_wallet&.downcase
      sufficient_amount = actual_value_wei >= required_value_wei
      sufficient_confirmations = tx["confirmations"].to_i >= min_confirmations
      valid_from_address = tx["from"]&.match?(/\A0x[a-fA-F0-9]{40}\z/)
      valid_tx_hash_format = tx_hash.match?(/\A0x[a-fA-F0-9]{64}\z/)

      Rails.logger.info "[BountyVerification] Security checks - recipient: #{valid_recipient}, amount: #{sufficient_amount}, confirmations: #{sufficient_confirmations} (#{tx["confirmations"]} >= #{min_confirmations}), from: #{valid_from_address}, hash_format: #{valid_tx_hash_format}"

      unless valid_recipient && sufficient_amount && sufficient_confirmations && valid_from_address && valid_tx_hash_format
        error_details = []
        error_details << "Invalid recipient" unless valid_recipient
        error_details << "Insufficient amount" unless sufficient_amount
        error_details << "Insufficient confirmations" unless sufficient_confirmations
        error_details << "Invalid sender address" unless valid_from_address
        error_details << "Invalid transaction hash format" unless valid_tx_hash_format

        Rails.logger.warn "[BountyVerification] Transaction validation failed: #{error_details.join(', ')}"
        render json: { success: false, error: "Transaction validation failed: #{error_details.join(', ')}" }, status: :unprocessable_entity and return
      end

      # All security checks passed - create bounty and record transaction
      ActiveRecord::Base.transaction do
        # Create the bounty record and mark it as paid (confirmed) since verification passed
        @bounty = @conjecture.bounties.create!(user: current_user, amount: amount, tx_hash: tx_hash, paid: true)

        # Record the processed transaction to prevent replay attacks
        ProcessedTransaction.create!(
          tx_hash: tx_hash,
          bounty: @bounty,
          user: current_user,
          amount: amount,
          from_address: tx["from"]
        )

        Rails.logger.info "[BountyVerification] Bounty created and marked as confirmed: #{@bounty.inspect}"
      end

      render json: { success: true }
    rescue => e
      Rails.logger.error "[BountyVerification] Exception: #{e.class} - #{e.message}\n#{e.backtrace.join("\n")}"
      render json: { success: false, error: e.message }, status: :unprocessable_entity
    end
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
