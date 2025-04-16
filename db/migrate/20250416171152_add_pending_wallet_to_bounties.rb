class AddPendingWalletToBounties < ActiveRecord::Migration[8.0]
  def change
    add_column :bounties, :pending_wallet, :boolean, default: false, null: false
  end
end
