require "test_helper"

class RefutationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @conjecture = conjectures(:active_conjecture)
    @user = users(:alice)
    @refutation = refutations(:bob_refutation)
    sign_in @user
  end

  test "should create refutation" do
    assert_difference("Refutation.count") do
      post conjecture_refutations_path(@conjecture), params: {
        refutation: { content: "This is a test refutation." }
      }
    end

    assert_redirected_to conjecture_path(@conjecture)
    assert_equal "Refutation was successfully added.", flash[:notice]
  end

  test "should destroy refutation" do
    # Ensure user owns the refutation
    @refutation.update(user: @user)

    assert_difference("Refutation.count", -1) do
      delete conjecture_refutation_path(@conjecture, @refutation)
    end

    assert_redirected_to conjecture_path(@conjecture)
    assert_equal "Refutation was successfully deleted.", flash[:notice]
  end

  test "should not destroy refutation created by another user" do
    # Ensure refutation is owned by a different user
    @refutation.update(user: users(:bob))

    assert_no_difference("Refutation.count") do
      delete conjecture_refutation_path(@conjecture, @refutation)
    end

    assert_redirected_to conjecture_path(@conjecture)
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end
end
