module Api
  module V1
    class UsersController < BaseController
      def show
        @user = User.where('lower(users.address) = ?', params[:id].downcase).first
        if @user
          render json: @user, serializer: UserSerializer, status: :ok
        else
          render json: { message: 'User not found', errors: 'not_found' }, status: :ok
        end
      end

      protected

      def user_params
        params.require(:user).permit(:id, :email)
      end
    end
  end
end
