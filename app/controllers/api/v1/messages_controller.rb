class Api::V1::MessagesController < ApplicationController

  before_action :doorkeeper_authorize!

  def create

    totals = params[:messages].map do |mes|
      begin
        message = Message.create(sender: mes[:sender], body: mes[:body], service: mes[:service], reciever: mes[:reciever], wn: Date.today.strftime("%U").to_i)
      rescue ActiveRecord::RecordNotUnique
        { status: 409, message: message, errors: 'Duplicate message violates unique constraint' }
      else
        if message.errors.present?
          { status: 422, message: message, errors: message.errors.full_messages }
        else
          Sender.delay.send_message(message)
          { status: 201, message: message }
        end
      end
    end

    render json: totals, status: 207

  end
end
