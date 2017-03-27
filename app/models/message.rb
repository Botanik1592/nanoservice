class Message < ApplicationRecord
  validates :sender, :body, :reciever, :service, presence: true
  validates :body, length: { minimum: 1 }
  validates :service, inclusion: { in: %w(whatsapp telegram viber),
    message: "%{value} is not a valid service" }
  validates_uniqueness_of :body, scope: [:sender, :service, :reciever], conditions: -> { where(created_at: Time.current.all_week) }
end
