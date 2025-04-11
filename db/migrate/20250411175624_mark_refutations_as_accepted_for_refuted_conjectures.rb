class MarkRefutationsAsAcceptedForRefutedConjectures < ActiveRecord::Migration[8.0]
  def up
    # Get all conjectures that are in the 'refuted' status
    refuted_conjectures = Conjecture.where(status: 1) # status 1 is 'refuted'

    puts "Found #{refuted_conjectures.count} refuted conjectures that need an accepted refutation."

    refuted_conjectures.each do |conjecture|
      # Find the most recent refutation for this conjecture
      latest_refutation = conjecture.refutations.order(created_at: :desc).first

      if latest_refutation
        # Mark the most recent refutation as accepted
        latest_refutation.update_column(:accepted, true)
        puts "Marked refutation #{latest_refutation.id} as accepted for conjecture #{conjecture.id} (#{conjecture.title})"
      else
        puts "Warning: Conjecture #{conjecture.id} (#{conjecture.title}) is marked as refuted but has no refutations."
      end
    end
  end

  def down
    # Reset all refutations for refuted conjectures back to not accepted
    refuted_conjectures = Conjecture.where(status: 1) # status 1 is 'refuted'

    refuted_conjectures.each do |conjecture|
      conjecture.refutations.update_all(accepted: false)
      puts "Reset acceptance status for all refutations of conjecture #{conjecture.id}"
    end
  end
end
