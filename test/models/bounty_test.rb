require "test_helper"

class BountyTest < ActiveSupport::TestCase
  test "should not save bounty without amount" do
    bounty = Bounty.new(user: users(:alice), conjecture: conjectures(:active_conjecture))
    assert_not bounty.save, "Saved the bounty without an amount"
  end

  test "should not save bounty with negative amount" do
    bounty = Bounty.new(
      amount: -10.0,
      user: users(:alice),
      conjecture: conjectures(:active_conjecture)
    )
    assert_not bounty.save, "Saved the bounty with a negative amount"
  end

  test "should not save bounty with zero amount" do
    bounty = Bounty.new(
      amount: 0,
      user: users(:alice),
      conjecture: conjectures(:active_conjecture)
    )
    assert_not bounty.save, "Saved the bounty with zero amount"
  end

  test "should save valid bounty" do
    bounty = Bounty.new(
      amount: 10.0,
      user: users(:alice),
      conjecture: conjectures(:active_conjecture)
    )
    assert bounty.save, "Could not save a valid bounty"
  end

  test "should belong to a user" do
    bounty = bounties(:alice_bounty)
    assert_equal users(:alice), bounty.user
  end

  test "should belong to a conjecture" do
    bounty = bounties(:alice_bounty)
    assert_equal conjectures(:published_conjecture), bounty.conjecture
  end
end
