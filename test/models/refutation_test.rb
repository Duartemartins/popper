require "test_helper"

class RefutationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "should be invalid with insult in content" do
    refutation = Refutation.new(content: "This is a dumb refutation", user: users(:alice), conjecture: conjectures(:active_conjecture))
    assert_not refutation.valid?
    assert_includes refutation.errors[:content], "contains disrespectful language: 'dumb' is not allowed"
  end
end
