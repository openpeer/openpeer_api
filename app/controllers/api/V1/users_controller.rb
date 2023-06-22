module Api
  module V1
    class UsersController < BaseController
      def show
        begin
          @user = User.find_or_create_by_address(params[:id].downcase)
        rescue Eth::Address::CheckSumError
          @user = nil
        end

        if @user
          render json: @user, serializer: UserSerializer, status: :ok, root: 'data'
        else
          render json: { data: { message: 'User not found', errors: 'not_found' } }, status: :ok
        end
      end
    end
  end
end
