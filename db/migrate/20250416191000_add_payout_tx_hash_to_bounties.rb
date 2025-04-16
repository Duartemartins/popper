class AddPayoutTxHashToBounties < ActiveRecord::Migration[6.1]
  def change
    add_column :bounties, :payout_tx_hash, :string
  end
end
