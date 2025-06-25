class User < ApplicationRecord
  has_secure_password
  has_many :tickets
  has_many :comments

  validates :email, presence: true, uniqueness: true
  validates :role, presence: true, inclusion: { in: %w[agent customer] }
end
