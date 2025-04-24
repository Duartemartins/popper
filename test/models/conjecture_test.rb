require "test_helper"

class ConjectureTest < ActiveSupport::TestCase
  test "should not save conjecture without title" do
    conjecture = Conjecture.new(
      description: "Test description",
      falsification_criteria: "Test criteria",
      user: users(:alice),
      status: :active
    )
    assert_not conjecture.save, "Saved the conjecture without a title"
  end

  test "should not save conjecture without description" do
    conjecture = Conjecture.new(
      title: "Test Title",
      falsification_criteria: "Test criteria",
      user: users(:alice),
      status: :active
    )
    assert_not conjecture.save, "Saved the conjecture without a description"
  end

  test "should not save conjecture without falsification criteria" do
    conjecture = Conjecture.new(
      title: "Test Title",
      description: "Test description",
      user: users(:alice),
      status: :active
    )
    assert_not conjecture.save, "Saved the conjecture without falsification criteria"
  end

  test "should save valid conjecture" do
    conjecture = Conjecture.new(
      title: "Test Title",
      description: "Test description",
      falsification_criteria: "Test criteria",
      user: users(:alice),
      status: :active
    )
    assert conjecture.save, "Could not save a valid conjecture"
  end

  test "should have correct total bounty" do
    conjecture = conjectures(:active_conjecture)
    # Active conjecture has Bob's 50.00 and Alice's 15.00 bounties, totaling 65.00
    assert_equal 65.00, conjecture.total_bounty
  end

  test "should handle zero bounties" do
    # Create a new conjecture with no bounties
    conjecture = Conjecture.create(
      title: "No Bounty",
      description: "This conjecture has no bounty",
      falsification_criteria: "Any evidence",
      user: users(:alice),
      status: :active
    )
    assert_equal 0, conjecture.total_bounty
  end

  test "should have multiple bounties" do
    conjecture = conjectures(:active_conjecture)
    assert_equal 2, conjecture.bounties.count
  end

  test "should destroy associated bounties when destroyed" do
    conjecture = conjectures(:active_conjecture)
    bounty_count = conjecture.bounties.count
    assert bounty_count > 0, "Should have bounties for this test to be meaningful"

    bounty_ids = conjecture.bounties.map(&:id)
    conjecture.destroy

    # None of the associated bounties should exist anymore
    bounty_ids.each do |id|
      assert_nil Bounty.find_by(id: id), "Bounty still exists after conjecture was destroyed"
    end
  end

  test "should default status to active" do
    conjecture = Conjecture.new(
      title: "Test Title",
      description: "Test description",
      falsification_criteria: "Test criteria",
      user: users(:alice)
      # Note: status is intentionally omitted
    )
    assert conjecture.active?, "Conjecture status should default to active"
    assert_equal :active, conjecture.status.to_sym, "Conjecture status symbol should be :active"
  end

  test "should be invalid with insult in title" do
    conjecture = Conjecture.new(title: "Stupid idea", description: "Test description", falsification_criteria: "Test criteria", user: users(:alice), status: :active)
    assert_not conjecture.valid?
    assert_includes conjecture.errors[:title], "contains disrespectful language: 'stupid' is not allowed"
  end

  test "should be invalid with insult in description" do
    conjecture = Conjecture.new(title: "Test Title", description: "Only an idiot would believe this", falsification_criteria: "Test criteria", user: users(:alice), status: :active)
    assert_not conjecture.valid?
    assert_includes conjecture.errors[:description], "contains disrespectful language: 'idiot' is not allowed"
  end
end
