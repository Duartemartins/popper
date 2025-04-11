require "test_helper"

class MetaImagesControllerTest < ActionDispatch::IntegrationTest
  test "should get generate" do
    get meta_images_generate_url
    assert_response :success
  end
end
