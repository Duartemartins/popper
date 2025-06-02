class Bounty < ApplicationRecord
  belongs_to :user
  belongs_to :conjecture
  belongs_to :refutation, optional: true
  has_one :processed_transaction, dependent: :destroy

  # Track whether bounty has been paid
  attribute :paid, :boolean, default: false
  # Timestamp when bounty was released to recipient
  attribute :released_at, :datetime

  validates :amount, presence: true, numericality: { greater_than: 0 }
end
