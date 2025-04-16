class AddCurrencyToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :currency, :string, null: false, default: ''
  end
end
