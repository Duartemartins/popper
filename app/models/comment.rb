class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true
  belongs_to :parent, class_name: "Comment", optional: true
  has_many :replies, class_name: "Comment", foreign_key: "parent_id", dependent: :destroy

  validates :content, presence: true, length: { minimum: 2, maximum: 1000 }
  validates :user, presence: true
  validates :commentable, presence: true

  private

  def content_must_be_respectful
    return if content.blank?
    ProfanityBlacklist::SERIOUS_PROFANITIES.each do |word|
      if content.downcase.include?(word)
        errors.add(:content, "contains serious profanity: '#{word}' is not allowed")
        break
      end
    end
  end

  validate :content_must_be_respectful
end
