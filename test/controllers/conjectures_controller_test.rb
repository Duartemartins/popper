require "test_helper"

class ConjecturesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get conjectures_index_url
    assert_response :success
  end

  test "should get show" do
    get conjectures_show_url
    assert_response :success
  end

  test "should get new" do
    get conjectures_new_url
    assert_response :success
  end

  test "should get create" do
    get conjectures_create_url
    assert_response :success
  end

  test "should get edit" do
    get conjectures_edit_url
    assert_response :success
  end

  test "should get update" do
    get conjectures_update_url
    assert_response :success
  end

  test "should get destroy" do
    get conjectures_destroy_url
    assert_response :success
  end
end
