class Sender
  require "net/http"
  require "uri"

  def self.send_message(message)
    # Отсюда будем вызывать необходимый для каждого сервиcа метод:
    if message.service == 'whatsapp'
      Sender.send_whatsapp(message)
    elsif message.service == 'telegram'
      Sender.send_telegram(message)
    else
      Sender.send_viber(message)
    end
  end

  def self.send_bad_messages
    messages = Message.find_by(status: false)
    messages.each do |message|
      Sender.send_message(message)
    end
  end

  def self.send_whatsapp(message)
    message = Sender.set_message(message.id)
    uri = URI.parse('http://whatsapp.service/send.php')
    response = Net::HTTP.post_form(uri,
      {
        "app_id" => Rails.application.secrets.whatsapp_app_id,
        "app_secret" => Rails.application.secrets.whatsapp_app_secret,
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

  def self.send_viber(message)
    message = Sender.set_message(message.id)
    uri = URI.parse('http://viber.service/send.php')
    response = Net::HTTP.post_form(uri,
      {
        "app_id" => Rails.application.secrets.viber_app_id,
        "app_secret" => Rails.application.secrets.viber_app_secret,
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

  def self.send_telegram(message)
    message = Sender.set_message(message.id)
    uri = URI.parse('http://telegram.service/send.php')
    response = Net::HTTP.post_form(uri,
      {
        "app_id" => Rails.application.secrets.telegram_app_id,
        "app_secret" => Rails.application.secrets.telegram_app_secret,
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

  def self.set_message(id)
    Message.find(id)
  end
end
