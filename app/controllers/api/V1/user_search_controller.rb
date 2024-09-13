# app/controllers/api/V1/user_search_controller.rb
module Api
  module V1
    class UserSearchController < BaseController
      def show
        begin
          @user = User.where('LOWER(address) = ?', params[:id].downcase).first
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