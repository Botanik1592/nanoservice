class Message < ApplicationRecord
  validates :sender, :body, :reciever, :service, presence: true
  validates :body, length: { minimum: 1 }
end
