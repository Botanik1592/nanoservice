class Api::V1::MessagesController < ApplicationController

  before_action :doorkeeper_authorize!

  def create
    errors = []
    arr = params.to_unsafe_h[:messages]

    arr.uniq.each do |mes|
      message = Message.create(mes.slice(:sender, :body, :service, :reciever))
      if message.errors.present?
        errors << message.errors.full_messages
      else
        Sender.delay.send_message(message)
      end
    end

    if errors.empty?
      render json: 'Accepted', status: 201
    else
      render json: {errors: errors}, status: 422
    end
  end
end
