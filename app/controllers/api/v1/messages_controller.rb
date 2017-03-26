class Api::V1::MessagesController < ApplicationController

  before_action :doorkeeper_authorize!

  def create
    totals = []

    params[:messages].each do |mes|
      search = Message.where(sender: mes[:sender], body: mes[:body], service: mes[:service], reciever: mes[:reciever], created_at: Time.current.all_week).first
      if search.present?
        totals << { status: 409, message: search, errors: 'Dublicated message.' }
      else
        message = Message.create(sender: mes[:sender], body: mes[:body], service: mes[:service], reciever: mes[:reciever])
        if message.errors.present?
          totals << { status: 422, message: message, errors: message.errors.full_messages }
        else
          Sender.delay.send_message(message)
          totals << { status: 201, message: message }
        end
      end
    end

    render json: totals, status: 207

  end
end
