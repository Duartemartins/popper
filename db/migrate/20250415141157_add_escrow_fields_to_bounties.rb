class AddEscrowFieldsToBounties < ActiveRecord::Migration[8.0]
  def change
    add_column :bounties, :released_at, :datetime
    add_column :bounties, :stripe_transfer_id, :string
  end
end
