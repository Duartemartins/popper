class Conjecture < ApplicationRecord
  belongs_to :user
  has_many :refutations, dependent: :destroy

  enum :status, { draft: 0, active: 1, published: 2 }

  validates :title, presence: true
  validates :description, presence: true
  validates :falsification_criteria, presence: true
end
