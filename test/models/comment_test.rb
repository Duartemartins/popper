require "test_helper"

class CommentTest < ActiveSupport::TestCase
  def setup
    @user = users(:alice)
    @commentable = conjectures(:active_conjecture)
    @valid_content = "This is a valid comment."
  end

  test "top-level comment is valid with all attributes" do
    comment = Comment.new(content: @valid_content, user: @user, commentable: @commentable)
    assert comment.valid?
  end

  test "reply (single level) is valid with parent" do
    parent = Comment.create!(content: @valid_content, user: @user, commentable: @commentable)
    reply = Comment.new(content: "Reply to comment", user: @user, commentable: @commentable, parent: parent)
    assert reply.valid?
  end

  test "nested reply (reply to reply) is valid" do
    parent = Comment.create!(content: @valid_content, user: @user, commentable: @commentable)
    reply = Comment.create!(content: "First reply", user: @user, commentable: @commentable, parent: parent)
    nested_reply = Comment.new(content: "Nested reply", user: @user, commentable: @commentable, parent: reply)
    assert nested_reply.valid?
  end

  test "should be invalid without content" do
    comment = Comment.new(content: nil, user: @user, commentable: @commentable)
    assert_not comment.valid?
    assert_includes comment.errors[:content], "can't be blank"
  end

  test "should be invalid with too short content" do
    comment = Comment.new(content: "a", user: @user, commentable: @commentable)
    assert_not comment.valid?
    assert_includes comment.errors[:content], "is too short (minimum is 2 characters)"
  end

  test "should be invalid with too long content" do
    long_content = "a" * 1001
    comment = Comment.new(content: long_content, user: @user, commentable: @commentable)
    assert_not comment.valid?
    assert_includes comment.errors[:content], "is too long (maximum is 1000 characters)"
  end

  test "should be invalid without user" do
    comment = Comment.new(content: @valid_content, user: nil, commentable: @commentable)
    assert_not comment.valid?
    assert_includes comment.errors[:user], "must exist"
  end

  test "should be invalid without commentable" do
    comment = Comment.new(content: @valid_content, user: @user, commentable: nil)
    assert_not comment.valid?
    assert_includes comment.errors[:commentable], "must exist"
  end

  test "reply is valid if parent is set and attributes are valid" do
    parent = Comment.create!(content: @valid_content, user: @user, commentable: @commentable)
    reply = Comment.new(content: "Another reply", user: @user, commentable: @commentable, parent: parent)
    assert reply.valid?
  end

  test "reply is invalid without content" do
    parent = Comment.create!(content: @valid_content, user: @user, commentable: @commentable)
    reply = Comment.new(content: nil, user: @user, commentable: @commentable, parent: parent)
    assert_not reply.valid?
    assert_includes reply.errors[:content], "can't be blank"
  end

  test "should be invalid with insult in content" do
    comment = Comment.new(content: "You are an idiot", user: users(:alice), commentable: conjectures(:active_conjecture))
    assert_not comment.valid?
    assert_includes comment.errors[:content], "contains disrespectful language: 'idiot' is not allowed"
  end
end
