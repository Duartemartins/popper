class Refutation < ApplicationRecord
  belongs_to :conjecture
  belongs_to :user

  has_many :comments, as: :commentable, dependent: :destroy

  validates :content, presence: true

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
