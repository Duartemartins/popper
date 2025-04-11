class CreateTaggings < ActiveRecord::Migration[8.0]
  def change
    create_table :taggings do |t|
      t.references :conjecture, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end
  end
end
