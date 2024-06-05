module Api
  module V1
    class UserProfilesController < JwtController
      def show
        if current_user
          render json: current_user, serializer: UserSerializer, params: { show_email: true }, status: :ok, root: 'data'
        else
          render json: { data: { message: 'User not found', errors: 'not_found' }}, status: :ok
        end
      end

      def update
        if current_user.update(user_params)
          UpdateUserWorker.perform_async(current_user.id)
          render json: current_user, serializer: UserSerializer, params: { show_email: true }, status: :ok, root: 'data'
        else
          render json: { data: { message: 'User not updated', errors: current_user.errors }}, status: :ok
        end
      end

      def verify
        QuadrataVerificationStatus.perform_async(current_user.address, params[:chain_id])
        render json: {}, status: :ok
      end

      protected

      def user_params
        params.require(:user_profile).permit(:image, :email, :name, :twitter, :timezone, :available_from,
                                            :available_to, :weekend_offline)
      end
    end
  end
end
