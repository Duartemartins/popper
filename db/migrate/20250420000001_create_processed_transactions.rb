class CreateProcessedTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :processed_transactions do |t|
      t.string :tx_hash, null: false, index: { unique: true }
      t.bigint :bounty_id, null: false
      t.bigint :user_id, null: false
      t.decimal :amount, precision: 18, scale: 8, null: false
      t.string :from_address, null: false
      t.timestamps
    end

    add_foreign_key :processed_transactions, :bounties
    add_foreign_key :processed_transactions, :users
    add_index :processed_transactions, [ :user_id, :created_at ]
    add_index :processed_transactions, [ :bounty_id, :created_at ]
  end
end
