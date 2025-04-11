class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :conjectures, dependent: :destroy
  has_many :refutations, dependent: :destroy
  has_many :bounties, dependent: :destroy

  # Calculate total awarded bounty for this user
  def total_awarded_bounty
    # Find all accepted refutations by this user
    accepted_refutations = refutations.where(accepted: true)

    # Calculate the total bounty amount from all conjectures with accepted refutations
    bounty_total = 0

    accepted_refutations.each do |refutation|
      bounty_total += refutation.conjecture.total_bounty
    end

    bounty_total
  end
end
