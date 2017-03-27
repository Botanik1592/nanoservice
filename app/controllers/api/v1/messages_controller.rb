class Api::V1::MessagesController < ApplicationController

  before_action :doorkeeper_authorize!

  def create
    totals = []

    params[:messages].each do |mes|
      message = Message.create(sender: mes[:sender], body: mes[:body], service: mes[:service], reciever: mes[:reciever], wn: Date.today.strftime("%U").to_i)
      if message.errors.present?
        totals << { status: 422, message: message, errors: message.errors.full_messages }
      else
        Sender.delay.send_message(message)
        totals << { status: 201, message: message }
      end
    end

    render json: totals, status: 207

  end
end
