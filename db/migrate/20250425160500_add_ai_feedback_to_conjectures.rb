class AddAiFeedbackToConjectures < ActiveRecord::Migration[7.0]
  def change
    add_column :conjectures, :ai_feedback, :text
    add_column :conjectures, :ai_feedback_generated_at, :datetime
  end
end
