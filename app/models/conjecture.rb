class Conjecture < ApplicationRecord
  belongs_to :user
  has_many :refutations, dependent: :destroy
  has_many :bounties, dependent: :destroy

  enum :status, { draft: 0, active: 1, published: 2 }

  validates :title, presence: true
  validates :description, presence: true
  validates :falsification_criteria, presence: true

  def total_bounty
    bounties.sum(:amount)
  end
end
