# app/controllers/telegram_controller.rb
class TelegramController < ApplicationController
  skip_before_action :verify_authenticity_token

  def webhook
    # Parse the incoming update from Telegram
    update = Telegram::Bot::Types::Update.new(params)

    # Check if the update contains a message
    if update.message
      # Check if the message is a /start command
      if update.message.text.start_with?('/start')
        # Extract the unique identifier from the /start command
        unique_identifier = extract_unique_identifier(update.message.text)

        if unique_identifier
          # Find the user by their unique identifier
          user = User.find_by(unique_identifier: unique_identifier)

          if user
            # User found, extract Telegram chat_id and username
            chat_id = update.message.chat.id
            username = update.message.from.username

            # Update the user's Telegram details in the database
            user.update(telegram_userid: chat_id, telegram_username: username)

            # Send a welcome message to the user
            send_welcome_message(chat_id, user.name)
          else
            # User not found, handle the case
            send_message(update.message.chat.id, "User not found. Please make sure you entered the correct unique identifier.")
          end
        else
          # Unique identifier not provided, handle the case
          send_message(update.message.chat.id, "Please provide your unique identifier after the /start command.")
        end
      end
    end

    # Respond with a success status
    head :ok
  end

  private

  def extract_unique_identifier(text)
    # Extract the unique identifier from the /start command
    text.split(' ').second
  end

  def send_message(chat_id, text)
    # Send a message to the specified chat ID
    Telegram::Bot::Client.run(ENV['TELEGRAM_BOT_TOKEN']) do |bot|
      bot.api.send_message(chat_id: chat_id, text: text)
    end
  end

  def send_welcome_message(chat_id, user_name)
    message = "GM #{user_name}. You have just subscribed to receive OpenPeer trade notifications. Your unique chat ID is #{chat_id}. Please make sure I'm not muted!"
    send_message(chat_id, message)
  end
end
