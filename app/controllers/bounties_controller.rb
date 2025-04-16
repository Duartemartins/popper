class BountiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conjecture

  def create
    @bounty = @conjecture.bounties.build(bounty_params)
    @bounty.user = current_user
    @bounty.save
    redirect_to @conjecture, notice: 'Bounty added. Payout will be sent from Popper platform wallet.'
  end

  def release
    @bounty = @conjecture.bounties.find(params[:id])
    recipient = @conjecture.user
    amount_eth = @bounty.amount.to_f
    if recipient.eth_address.blank?
      redirect_to @conjecture, alert: 'Recipient does not have an Ethereum address.' and return
    end
    tx_hash = EthereumWallet.send_eth(recipient.eth_address, amount_eth)
    if tx_hash.present?
      @bounty.update!(released_at: Time.current, eth_tx_hash: tx_hash)
      redirect_to @conjecture, notice: "Bounty released to recipient! Ethereum tx: #{tx_hash}"
    else
      redirect_to @conjecture, alert: 'Failed to release bounty.'
    end
  end

  private

  def set_conjecture
    @conjecture = Conjecture.find(params[:conjecture_id])
  end

  def bounty_params
    params.require(:bounty).permit(:amount, :currency, :country)
  end
end
