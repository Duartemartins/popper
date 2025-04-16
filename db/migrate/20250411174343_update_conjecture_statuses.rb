class UpdateConjectureStatuses < ActiveRecord::Migration[8.0]
  def up
    # Create a temporary backup of the status values
    add_column :conjectures, :old_status, :integer

    # Copy current status values to the backup column
    Conjecture.find_each do |conjecture|
      conjecture.update_column(:old_status, conjecture.status)
    end

    # Reset the status column with the new enum values
    if ActiveRecord::Base.connection.table_exists?(:active_record_internal_metadata)
      Conjecture.connection.execute("DELETE FROM active_record_internal_metadata WHERE key = 'conjecture_statuses'")
    end

    # Change the column default to 0 (active)
    change_column_default :conjectures, :status, 0

    # Update existing records:
    # - draft and published become active (0)
    # - keep active as active (0)
    # - no records are set to refuted (1) as this is a new status
    Conjecture.find_each do |conjecture|
      if [ 0, 2 ].include?(conjecture.old_status) # draft or published
        conjecture.update_column(:status, 0) # active
      elsif conjecture.old_status == 1 # active
        conjecture.update_column(:status, 0) # still active
      end
    end

    # Remove the temporary backup column
    remove_column :conjectures, :old_status
  end

  def down
    # We can't fully restore the original three statuses accurately
    # So we'll just warn that this migration can't be reversed cleanly
    raise ActiveRecord::IrreversibleMigration,
          "Can't revert from two-status system (active/refuted) back to three-status system (draft/active/published)"
  end
end
