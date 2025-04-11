class Conjecture < ApplicationRecord
  belongs_to :user
  has_many :refutations, dependent: :destroy
  has_many :bounties, dependent: :destroy
  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings

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
end
