class CreateRefutations < ActiveRecord::Migration[8.0]
  def change
    create_table :refutations do |t|
      t.text :content
      t.references :conjecture, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
