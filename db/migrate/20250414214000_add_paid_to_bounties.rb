class AddPaidToBounties < ActiveRecord::Migration[8.0]
  def change
    add_column :bounties, :paid, :boolean, default: false
  end
end
