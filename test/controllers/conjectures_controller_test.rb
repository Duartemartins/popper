require "test_helper"

class ConjecturesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:alice)
    @conjecture = conjectures(:active_conjecture)
    sign_in @user
  end

  test "should get index" do
    get conjectures_path
    assert_response :success
  end

  test "should get show" do
    get conjecture_path(@conjecture)
    assert_response :success
  end

  test "should get new" do
    get new_conjecture_path
    assert_response :success
  end

  test "should create conjecture" do
    assert_difference("Conjecture.count") do
      post conjectures_path, params: {
        conjecture: {
          title: "Test Conjecture",
          description: "This is a test description",
          falsification_criteria: "This can be falsified if...",
          status: "active"
        }
      }
    end

    assert_redirected_to conjecture_path(Conjecture.last)
  end

  test "should get edit" do
    get edit_conjecture_path(@conjecture)
    assert_response :success
  end

  test "should update conjecture" do
    patch conjecture_path(@conjecture), params: {
      conjecture: {
        title: "Updated Title",
        description: @conjecture.description,
        falsification_criteria: @conjecture.falsification_criteria
      }
    }

    assert_redirected_to conjecture_path(@conjecture)
    @conjecture.reload
    assert_equal "Updated Title", @conjecture.title
  end

  test "should destroy conjecture" do
    # Make sure the user owns the conjecture
    @conjecture.update(user: @user)

    assert_difference("Conjecture.count", -1) do
      delete conjecture_path(@conjecture)
    end

    assert_redirected_to conjectures_path
  end

  test "should not allow editing another user's conjecture" do
    # Make sure the conjecture is owned by another user
    @conjecture.update(user: users(:bob))

    get edit_conjecture_path(@conjecture)
    assert_redirected_to conjectures_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  test "should not destroy conjecture with accepted refutation" do
    # Make sure the user owns the conjecture
    @conjecture.update(user: @user)
    # Create an accepted refutation
    accepted_refutation = @conjecture.refutations.create!(user: @user, content: "Accepted!", accepted: true)
    
    assert_no_difference("Conjecture.count") do
      delete conjecture_path(@conjecture)
    end
    
    assert_redirected_to conjecture_path(@conjecture)
    assert_equal "You cannot delete a conjecture with an accepted refutation.", flash[:alert]
  end
end
