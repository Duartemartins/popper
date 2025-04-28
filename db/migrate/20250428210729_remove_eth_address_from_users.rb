class RemoveEthAddressFromUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :eth_address, :string
  end
end
