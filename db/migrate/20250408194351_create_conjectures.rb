class CreateConjectures < ActiveRecord::Migration[8.0]
  def change
    create_table :conjectures do |t|
      t.string :title
      t.text :description
      t.text :falsification_criteria
      t.integer :status
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
