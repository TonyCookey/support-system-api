class Ticket < ApplicationRecord
  belongs_to :user
  has_many :comments
  has_many_attached :attachments

  validates :title, presence: true
  validates :description, presence: true
  enum status: { open: "open", in_progress: "in_progress", closed: "closed" }
end
