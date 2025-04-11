require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should have conjectures" do
    assert_not_empty users(:alice).conjectures
  end

  test "should have refutations" do
    assert_not_empty users(:alice).refutations
  end

  test "should have bounties" do
    assert_not_empty users(:alice).bounties
  end

  test "should destroy associated conjectures when destroyed" do
    user = users(:alice)
    conjecture_count = user.conjectures.count
    assert conjecture_count > 0, "Should have conjectures for this test to be meaningful"

    conjecture_ids = user.conjectures.map(&:id)
    user.destroy

    # None of the associated conjectures should exist anymore
    conjecture_ids.each do |id|
      assert_nil Conjecture.find_by(id: id), "Conjecture still exists after user was destroyed"
    end
  end

  test "should destroy associated bounties when destroyed" do
    user = users(:alice)
    bounty_count = user.bounties.count
    assert bounty_count > 0, "Should have bounties for this test to be meaningful"

    bounty_ids = user.bounties.map(&:id)
    user.destroy

    # None of the associated bounties should exist anymore
    bounty_ids.each do |id|
      assert_nil Bounty.find_by(id: id), "Bounty still exists after user was destroyed"
    end
  end
end
