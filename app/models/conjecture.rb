class Conjecture < ApplicationRecord
  belongs_to :user
  has_many :refutations, dependent: :destroy
  has_many :bounties, dependent: :destroy
  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings
  has_many :comments, as: :commentable, dependent: :destroy

  attribute :status, :integer, default: 0 # Set default status to :active
  enum :status, { active: 0, refuted: 1 }

  validates :title, presence: true
  validates :description, presence: true
  validates :falsification_criteria, presence: true

  def total_bounty
    bounties.sum(:amount)
  end

  def tag_list
    tags.map(&:name).join(", ")
  end

  def tag_list=(names)
    tag_names = names.split(",").map(&:strip).reject(&:empty?).map(&:downcase).uniq

    self.tags = tag_names.map do |tag_name|
      Tag.find_or_create_by(name: tag_name)
    end
  end

  validate :title_must_be_respectful
  validate :description_must_be_respectful

  private

  def title_must_be_respectful
    return if title.blank?
    ProfanityBlacklist::SERIOUS_PROFANITIES.each do |word|
      if title.downcase.include?(word)
        errors.add(:title, "contains serious profanity: '#{word}' is not allowed")
        break
      end
    end
  end

  def description_must_be_respectful
    return if description.blank?
    ProfanityBlacklist::SERIOUS_PROFANITIES.each do |word|
      if description.downcase.include?(word)
        errors.add(:description, "contains serious profanity: '#{word}' is not allowed")
        break
      end
    end
  end
end
