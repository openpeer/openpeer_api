require 'knock'

class UpdateUserWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find(user_id)
    Knock::Users.identify(id: user.address, data: { name: user.name, email: user.email })
    
    return unless ENV['WALLET_CHAT_API_KEY'].present?

    url = 'https://api.v2.walletchat.fun/v1/name'
    headers = {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{ENV['WALLET_CHAT_API_KEY']}"
    }
    payload = {
      address: user.address,
      email: user.email,
      name:  user.name,
      signupsite:  'app.openpeer.xyz',
      domain: 'openpeer.xyz'
    }.to_json
    
    RestClient.post(url, payload, headers)
  end
end
