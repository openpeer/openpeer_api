require 'knock'

class UpdateUserKnock
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find(user_id)
    Knock::Users.identify(id: user.address, data: { name: user.name, email: user.email })
  end
end
