require "test_helper"

class BountiesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @conjecture = conjectures(:active_conjecture)
    @user = users(:alice)
    sign_in @user
  end

  test "should create bounty" do
    assert_difference("Bounty.count") do
      post conjecture_bounties_path(@conjecture), params: {
        bounty: { amount: 25.50 }
      }
    end

    assert_redirected_to conjecture_path(@conjecture)
    assert_equal "Bounty was successfully added.", flash[:notice]

    # Verify the bounty was created with correct attributes
    bounty = Bounty.last
    assert_equal 25.50, bounty.amount
    assert_equal @user.id, bounty.user_id
    assert_equal @conjecture.id, bounty.conjecture_id
  end

  test "should not create bounty with invalid amount" do
    assert_no_difference("Bounty.count") do
      post conjecture_bounties_path(@conjecture), params: {
        bounty: { amount: -10 }
      }
    end

    assert_redirected_to conjecture_path(@conjecture)
    assert flash[:alert].present?
  end

  test "should require login to create bounty" do
    sign_out @user

    assert_no_difference("Bounty.count") do
      post conjecture_bounties_path(@conjecture), params: {
        bounty: { amount: 25.50 }
      }
    end

    assert_redirected_to new_user_session_path
  end
end
