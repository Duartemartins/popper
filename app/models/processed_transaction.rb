class ProcessedTransaction < ApplicationRecord
  belongs_to :bounty
  belongs_to :user
  
  validates :tx_hash, presence: true, uniqueness: true, format: { with: /\A0x[a-fA-F0-9]{64}\z/, message: "must be a valid transaction hash" }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :from_address, presence: true, format: { with: /\A0x[a-fA-F0-9]{40}\z/, message: "must be a valid Ethereum address" }
  
  scope :recent, -> { where(created_at: 1.hour.ago..Time.current) }
  scope :for_user, ->(user) { where(user: user) }
  scope :for_bounty, ->(bounty) { where(bounty: bounty) }
end
