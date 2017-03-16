class Api::V1::MessagesController < ApplicationController

  SERVICES_LIST = %w(whatsapp telegram viber)

  before_action :doorkeeper_authorize!

  def create
    if params[:reciever].present?
      params[:reciever].each do |service, reciever|
        if SERVICES_LIST.include?(service) && reciever.present?
          message = Message.create(sender: params[:sender], body: params[:body], service: service, reciever: reciever)
          if message.errors.present?
            return render json: { errors: message.errors.full_messages }, status: 422
          else
            Sender.delay.send_message(message)
          end
        else
          render json: { errors: 'Unknown service' }, status: 422
        end
      end
      render json: 'Accepted', status: 201
    else
      render json: { errors: 'Service is blank' }, status: 422
    end
  end
end
