module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      token = JsonWebToken.decode(request.params[:token])
      address = token['verified_credentials'].first['address']
      exp = token['exp']

      if (current_user = User.find_or_create_by_address(address)) && exp > Time.now.to_i
        current_user
      else
        reject_unauthorized_connection
      end
    end
  end
end
