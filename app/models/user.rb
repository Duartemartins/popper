class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :conjectures, dependent: :destroy
  has_many :refutations, dependent: :destroy
  has_many :bounties, dependent: :destroy
end
