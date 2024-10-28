# app/services/talkjs/user_service.rb
require 'jwt'
require 'httparty'

class Talkjs::UserService
  class Error < StandardError; end

  def initialize
    @app_id = ENV.fetch('TALKJS_APP_ID') { raise Error.new("TALKJS_APP_ID not set") }
    @secret_key = ENV.fetch('TALKJS_SECRET_KEY') { raise Error.new("TALKJS_SECRET_KEY not set") }
    @base_url = "https://api.talkjs.com/v1/#{@app_id}"
  end

  def list_users(limit: 100, starting_after: nil, is_online: nil)
    token = generate_token
    
    query_params = {
      limit: limit
    }
    query_params[:startingAfter] = starting_after if starting_after
    query_params[:isOnline] = is_online unless is_online.nil?
    
    url = "#{@base_url}/users?#{query_params.to_query}"
    
    # Debug output
    puts "\nDebug: Request details"
    puts "URL: #{url}"
    puts "Token: #{token[0..20]}..."
    puts "App ID: #{@app_id}"
    
    response = HTTParty.get(
      url,
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{token}"
      }
    )

    # Debug output
    puts "Response Status: #{response.code}"
    puts "Response Body: #{response.body[0..200]}..." if response.body

    unless response.success?
      raise Error, "Failed to fetch users: #{response.body}"
    end

    parsed_response = JSON.parse(response.body)
    
    {
      data: parsed_response['data'],
      next_page_cursor: get_next_page_cursor(parsed_response['data'], limit)
    }
  end

  def get_user(user_id)
    token = generate_token
    
    response = HTTParty.get(
      "#{@base_url}/users/#{user_id}",
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{token}"
      }
    )

    unless response.success?
      raise Error, "Failed to fetch user #{user_id}: #{response.body}"
    end

    JSON.parse(response.body)
  end

  private

  def generate_token
    payload = {
      tokenType: 'app',          # Changed from scope: 'app'
      iss: @app_id,             # issuer
      exp: Time.now.to_i + 30   # expiry time in seconds from now
    }

    JWT.encode(payload, @secret_key, 'HS256')
  end

  def get_next_page_cursor(data, limit)
    return nil if !data || data.empty? || data.length < limit
    data.last['id']
  end
end