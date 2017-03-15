class Api::V1::MessagesController < ApplicationController

  SERVICES_LIST = %w(whatsapp telegram viber)

  before_action :doorkeeper_authorize!

  respond_to :json

  def create
    if params[:reciever].present?
      errors = []
      params[:reciever].each do |service, reciever|
        if SERVICES_LIST.include?(service)
          message = Message.create(sender: params[:sender], body: params[:body], service: service, reciever: reciever)
          Sender.delay.send_message(message)
          if message.errors.present?
            errors << message.errors
          end
        else
          render :json => 'Unknown service', :status => 422
        end
      end
      if errors.empty?
        render :json => 'Accepted', :status => 201
      else
        render :json => errors, :status => 422
      end
    else
      render :json => 'Service is blank', :status => 422
    end
  end
end
