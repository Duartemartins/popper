class Bounty < ApplicationRecord
  belongs_to :user
  belongs_to :conjecture

  validates :amount, presence: true, numericality: { greater_than: 0 }
end
