class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy
  has_many :conjectures, through: :taggings

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  before_save :downcase_name

  private

  def downcase_name
    self.name = name.downcase if name.present?
  end
end
