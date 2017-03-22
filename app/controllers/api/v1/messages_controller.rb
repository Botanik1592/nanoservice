class Api::V1::MessagesController < ApplicationController

  before_action :doorkeeper_authorize!

  def create
    errors = []

    params.to_unsafe_h[:messages].uniq.each do |mes|
      message = Message.create(mes.slice(:sender, :body, :service, :reciever))
      if message.errors.present?
        errors << { status: 422, message: message, errors: message.errors.full_messages }
      else
        Sender.delay.send_message(message)
      end
    end

    if errors.empty?
      render json: {message: 'Ok'}, status: 201
    else
      render json: errors, status: 207
    end
  end
end
