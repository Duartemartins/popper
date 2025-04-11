require "test_helper"

class BountiesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:alice)
    @conjecture = conjectures(:active_conjecture)
    sign_in @user
  end

  test "user can view bounty information on conjecture page" do
    get conjecture_path(@conjecture)
    assert_response :success

    # Check that the page displays the total bounty amount
    assert_select "div.text-green-600", /\$#{@conjecture.total_bounty}/

    # Check that the bounty form is present for logged in users
    assert_select "form[action=?]", conjecture_bounties_path(@conjecture)
    assert_select "input[name='bounty[amount]']"
    assert_select "input[type=submit][value=?]", "Add to Bounty"
  end

  test "user can add bounty to a conjecture" do
    initial_bounty = @conjecture.total_bounty
    new_amount = 10.00

    post conjecture_bounties_path(@conjecture), params: {
      bounty: { amount: new_amount }
    }

    # Verify redirect and flash message
    assert_redirected_to conjecture_path(@conjecture)
    assert_equal "Bounty was successfully added.", flash[:notice]

    # Check database was updated
    @conjecture.reload
    assert_equal initial_bounty + new_amount, @conjecture.total_bounty

    # Visit the page again to see the updated bounty
    get conjecture_path(@conjecture)
    assert_select "div.text-green-600", /\$#{@conjecture.total_bounty}/
  end

  test "bounty amount shows up on conjecture index page" do
    # Make sure we have a conjecture with a bounty
    assert @conjecture.total_bounty > 0, "Test conjecture should have a bounty"

    get conjectures_path
    assert_response :success

    # Check that the bounty is displayed on the index page
    assert_select "div", html: /.*#{@conjecture.title}.*/ do
      assert_select "span.text-green-600", /\$#{@conjecture.total_bounty}/
    end
  end

  test "non-logged in users cannot add bounties" do
    sign_out @user

    get conjecture_path(@conjecture)
    assert_response :success

    # Check that the page shows the login message instead of the form
    assert_select "form[action=?]", conjecture_bounties_path(@conjecture), count: 0
    assert_select "div.bg-gray-50", /You must be signed in to contribute to the bounty/
    assert_select "a[href=?]", new_user_session_path, "Sign in"
  end
end
