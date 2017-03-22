class Api::V1::MessagesController < ApplicationController

  before_action :doorkeeper_authorize!

  def create
    errors = {}

    params.to_unsafe_h[:messages].uniq.each_with_index do |mes, i|
      message = Message.create(mes.slice(:sender, :body, :service, :reciever))
      if message.errors.present?
        errors[i] = message.errors.full_messages
      else
        Sender.delay.send_message(message)
      end
    end

    if errors.empty?
      render json: {message: 'Ok'}, status: 201
    else
      render json: {message: 'A few errors occurred', errors: errors}, status: 422
    end
  end
end
