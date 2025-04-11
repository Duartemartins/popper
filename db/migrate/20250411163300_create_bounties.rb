class CreateBounties < ActiveRecord::Migration[8.0]
  def change
    create_table :bounties do |t|
      t.decimal :amount
      t.references :user, null: false, foreign_key: true
      t.references :conjecture, null: false, foreign_key: true

      t.timestamps
    end
  end
end
