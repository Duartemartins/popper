class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Define standard recognized titles
  TITLES = [
    "Mr.", "Mrs.", "Ms.", "Miss", "Dr.", "Prof.", "Sir", "Dame",
    "Lady", "Lord", "Rev.", "Hon.", "Capt.", "Col.", "Maj."
  ].freeze

  has_many :conjectures, dependent: :destroy
  has_many :refutations, dependent: :destroy
  has_many :bounties, dependent: :destroy
  has_many :comments, dependent: :destroy

  # Define display name preferences as an enum
  enum :display_name_preference, {
    anonymous: 0,        # Don't show any identifying info
    username_only: 1,    # Show only username
    full_name: 2,        # Show full name (first + last)
    full_name_with_title: 3  # Show title + full name
  }

  # Devise admin flag
  attribute :admin, :boolean, default: false

  # Add Ethereum/Sonic wallet address for crypto onboarding
  attribute :wallet_address, :string
  validates :wallet_address, uniqueness: true, allow_blank: true

  # Removed Rapyd/country/currency logic. This model will be updated for crypto onboarding.

  # Validations
  validates :username, uniqueness: true, allow_blank: true
  validates :username, presence: true, if: -> { display_name_preference == "username_only" }
  validates :first_name, :last_name, presence: true, if: -> { full_name? || full_name_with_title? }
  validates :title, presence: true, if: -> { full_name_with_title? }
  validates :title, inclusion: { in: TITLES }, allow_blank: true

  # Returns true if the user has set their name
  def has_name_set?
    first_name.present? && last_name.present?
  end

  # Returns user initials for avatars when no profile picture is available
  def initials
    if has_name_set?
      "#{first_name[0]}#{last_name[0]}".upcase
    elsif username.present?
      username[0..1].upcase
    else
      "AN" # Anonymous
    end
  end

  # Returns the user's display name based on their preference
  def display_name
    base_name = case display_name_preference
    when "anonymous"
      "Anonymous User"
    when "username_only"
      username.presence || "Anonymous User"
    when "full_name"
      if first_name.present? && last_name.present?
        "#{first_name} #{last_name}"
      else
        "Anonymous User"
      end
    when "full_name_with_title"
      if title.present? && first_name.present? && last_name.present?
        "#{title} #{first_name} #{last_name}"
      else
        "Anonymous User"
      end
    else
      "Anonymous User"
    end

    # Don't append organization for anonymous users or if base_name is already "Anonymous User"
    if organization.present? && display_name_preference != "anonymous" && base_name != "Anonymous User"
      "#{base_name}, #{organization}"
    else
      base_name
    end
  end

  # Returns just the name portion without organization
  def name_only
    case display_name_preference
    when "anonymous"
      "Anonymous User"
    when "username_only"
      username.presence || "Anonymous User"
    when "full_name"
      if first_name.present? && last_name.present?
        "#{first_name} #{last_name}"
      else
        "Anonymous User"
      end
    when "full_name_with_title"
      if title.present? && first_name.present? && last_name.present?
        "#{title} #{first_name} #{last_name}"
      else
        "Anonymous User"
      end
    else
      "Anonymous User"
    end
  end

  # Calculate total awarded bounty for this user
  def total_awarded_bounty
    # Find all accepted refutations by this user
    accepted_refutations = refutations.where(accepted: true)

    # Calculate the total bounty amount from all conjectures with accepted refutations
    bounty_total = 0

    accepted_refutations.each do |refutation|
      # Only count bounties that have been released
      bounty_total += refutation.conjecture.bounties.where.not(released_at: nil).sum(:amount)
    end

    bounty_total
  end

  # Calculate total received from Popper wallet (actual payouts to user's wallet)
  def total_received_from_platform
    Bounty.where.not(released_at: nil)
      .where(user_id: id)
      .sum(:amount)
  end
end
