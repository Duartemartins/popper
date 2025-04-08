require "test_helper"

class RefutationsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get refutations_create_url
    assert_response :success
  end

  test "should get destroy" do
    get refutations_destroy_url
    assert_response :success
  end
end
