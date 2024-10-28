# app/services/talkjs/user_sync_service.rb
require 'jwt'

class Talkjs::UserSyncService
  class SyncError < StandardError; end

  def initialize
    @app_id = ENV.fetch('TALKJS_APP_ID')
    @secret_key = ENV.fetch('TALKJS_SECRET_KEY')
    @base_url = "https://api.talkjs.com/v1/#{@app_id}"
  end

  # Sync a single user
  def sync_user(user)
    token = generate_token
    response = HTTParty.put(
      "#{@base_url}/users/#{user.id}",  # Changed from unique_identifier to id
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{token}"
      },
      body: user_payload(user).to_json
    )

    unless response.success?
      raise SyncError, "Failed to sync user #{user.id}: #{response.body}"
    end

    response
  end

  # Batch sync multiple users
  def batch_sync_users(users)
    token = generate_token
    payload = users.reduce({}) do |acc, user|
      acc[user.id.to_s] = user_payload(user)  # Changed from unique_identifier to id, ensure it's a string
      acc
    end

    response = HTTParty.put(
      "#{@base_url}/users",
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{token}"
      },
      body: payload.to_json
    )

    unless response.success?
      raise SyncError, "Failed to batch sync users: #{response.body}"
    end

    response
  end

  # Sync all users in batches
  def sync_all_users(batch_size: 100)
    User.find_each(batch_size: batch_size) do |batch|
      batch_sync_users(batch)
    end
  end

  private

  def user_payload(user)
    {
      name: user.name,
      email: [user.email].compact,
      photoUrl: user.image_url,
      role: 'user'
    }.compact
  end

  def generate_token
    payload = {
      tokenType: 'app',
      iss: @app_id,
      exp: Time.now.to_i + 30
    }

    JWT.encode(payload, @secret_key, 'HS256')
  end
end