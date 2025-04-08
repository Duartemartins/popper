class Refutation < ApplicationRecord
  belongs_to :conjecture
  belongs_to :user

  validates :content, presence: true
end
