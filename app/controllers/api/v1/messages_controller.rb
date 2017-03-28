class Api::V1::MessagesController < ApplicationController

  before_action :doorkeeper_authorize!

  def create

    totals = params[:messages].map do |mes|
      begin
        message = Message.create(sender: mes[:sender], body: mes[:body], service: mes[:service], reciever: mes[:reciever], wn: Date.today.strftime("%U").to_i)
      rescue ActiveRecord::RecordNotUnique
        { status: :conflict, message: message, errors: ["There's exactly the same message already in our database"] }
      else
        if message.errors.present?
          { status: :unprocessable_entity, message: message, errors: message.errors.full_messages }
        else
          Sender.delay.send_message(message)
          { status: :created, message: message }
        end
      end
    end

    render json: totals, status: :multi_status

  end
end
