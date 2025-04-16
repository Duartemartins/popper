class AddRefutationIdToBounties < ActiveRecord::Migration[8.0]
  def change
    add_reference :bounties, :refutation, null: true, foreign_key: true
  end
end
