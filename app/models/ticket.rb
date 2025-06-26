class Ticket < ApplicationRecord
  belongs_to :user
  has_many :comments
  has_many_attached :attachments

  validates :title, presence: true
  validates :description, presence: true
  validates :status, inclusion: { in: %w[open closed in_progress] }, allow_nil: false
end
