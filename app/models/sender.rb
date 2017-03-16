class Sender
  require "net/http"
  require "uri"

  def self.send_message(message)
    if message.service == 'whatsapp'
      appid = Rails.application.secrets.whatsapp_app_id
      appsecret = Rails.application.secrets.whatsapp_app_secret
    elsif message.service == 'telegram'
      appid = Rails.application.secrets.telegram_app_id
      appsecret = Rails.application.secrets.telegram_app_secret
    else
      appid = Rails.application.secrets.viber_app_id
      appsecret = Rails.application.secrets.viber_app_secret
    end
    uri = URI.parse("http://#{message.service}.service/send.php")
    response = Net::HTTP.post_form(uri,
      {
        "app_id" => appid,
        "app_secret" => appsecret,
        "reciever" => message.reciever,
        "sender" => message.sender,
        "message" => message.body
      })
    if response == 'Delivered'
      message.destroy
    else
      message.tries += 1
      if message.status >= 3
        message.destroy
      end
    end
  end

  def self.send_bad_messages
    messages = Message.find_by(status: false)
    messages.each do |message|
      Sender.send_message(message)
    end
  end
end
