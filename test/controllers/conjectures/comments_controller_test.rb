require "test_helper"

class Conjectures::CommentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @conjecture = conjectures(:active_conjecture)
    @user = users(:alice)
    @other_user = users(:bob)
    @comment = comments(:one)
  end

  test "should require login to create comment" do
    assert_no_difference 'Comment.count' do
      post conjecture_comments_path(@conjecture), params: { comment: { content: "Test comment" } }
    end
    assert_redirected_to new_user_session_path
  end

  test "should create top-level comment when logged in" do
    sign_in @user
    assert_difference 'Comment.count', 1 do
      post conjecture_comments_path(@conjecture), params: { comment: { content: "A thoughtful comment" } }
    end
    assert_redirected_to conjecture_path(@conjecture)
    follow_redirect!
    assert_match 'Comment posted.', response.body
  end

  test "should not create invalid comment" do
    sign_in @user
    assert_no_difference 'Comment.count' do
      post conjecture_comments_path(@conjecture), params: { comment: { content: "" } }
    end
    assert_redirected_to conjecture_path(@conjecture)
    follow_redirect!
    assert_match 'Failed to post comment.', response.body
  end

  test "should create reply when logged in" do
    sign_in @user
    parent = Comment.create!(content: "Parent", user: @user, commentable: @conjecture)
    assert_difference 'Comment.count', 1 do
      post conjecture_comments_path(@conjecture), params: { comment: { content: "Reply comment", parent_id: parent.id } }
    end
    assert_redirected_to conjecture_path(@conjecture)
    follow_redirect!
    assert_match 'Comment posted.', response.body
    assert_equal parent.id, Comment.last.parent_id
  end

  test "should not create invalid reply" do
    sign_in @user
    parent = Comment.create!(content: "Parent", user: @user, commentable: @conjecture)
    assert_no_difference 'Comment.count' do
      post conjecture_comments_path(@conjecture), params: { comment: { content: "", parent_id: parent.id } }
    end
    assert_redirected_to conjecture_path(@conjecture)
    follow_redirect!
    assert_match 'Failed to post comment.', response.body
  end

  test "should require login to destroy comment" do
    assert_no_difference 'Comment.count' do
      delete conjecture_comment_path(@conjecture, @comment)
    end
    assert_redirected_to new_user_session_path
  end

  test "should destroy comment when logged in" do
    sign_in @user
    comment = Comment.create!(content: "To delete", user: @user, commentable: @conjecture)
    assert_difference 'Comment.count', -1 do
      delete conjecture_comment_path(@conjecture, comment)
    end
    assert_redirected_to conjecture_path(@conjecture)
    follow_redirect!
    assert_match 'Comment deleted.', response.body
  end
end
