class AddAcceptedToRefutations < ActiveRecord::Migration[8.0]
  def change
    add_column :refutations, :accepted, :boolean, default: false, null: false
  end
end
