class AddWalletAddressToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :wallet_address, :string
  end
end
