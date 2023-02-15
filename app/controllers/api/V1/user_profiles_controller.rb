module Api
  module V1
    class UserProfilesController < JwtController
      def show
        if current_user
          render json: current_user, serializer: UserSerializer, params: { show_email: true }, status: :ok
        else
          render json: { message: 'User not found', errors: 'not_found' }, status: :ok
        end
      end

      def update
        if current_user.update(user_params)
          render json: current_user, serializer: UserSerializer, params: { show_email: true }, status: :ok
        else
          render json: { message: 'User not updated', errors: current_user.errors }, status: :ok
        end
      end

      protected

      def user_params
        params.require(:user_profile).permit(:image, :email, :name, :twitter)
      end
    end
  end
end
