# app/controllers/api/V1/user_profiles_controller.rb
module Api
  module V1
    class UserProfilesController < JwtController
      def show
        begin
          if current_user
            render json: current_user, serializer: UserSerializer, params: { show_email: true }, status: :ok, root: 'data'
          else
            render json: { data: { message: 'User not found', errors: 'not_found' }}, status: :ok
          end
        rescue => e
          Rails.logger.error("Error in UserProfilesController#show: #{e.message}")
          Rails.logger.error(e.backtrace.join("\n"))
          render json: { data: { message: 'An error occurred', errors: 'internal_server_error' }}, status: :internal_server_error
        end
      end

      def update
        if current_user.update(user_params)
          UpdateUserWorker.perform_async(current_user.id)
          render json: current_user, serializer: UserSerializer, params: { show_email: true }, status: :ok, root: 'data'
        else
          Rails.logger.error("User update failed: #{current_user.errors.full_messages.join(', ')}")
          if current_user.errors[:name].include?("has already been taken")
            render json: { data: { message: 'Username already exists', errors: current_user.errors.full_messages }}, status: :unprocessable_entity
          else
            render json: { data: { message: 'User not updated', errors: current_user.errors.full_messages }}, status: :unprocessable_entity
          end
        end
      end

      def verify
        QuadrataVerificationStatus.perform_async(current_user.address, params[:chain_id])
        render json: {}, status: :ok
      end

      protected

      def user_params
        params.require(:user_profile).permit(:image, :email, :name, :twitter, :timezone, :available_from,
        :available_to, :weekend_offline, :telegram_user_id, :telegram_username, :whatsapp_country_code, :whatsapp_number)
      end
    end
  end
end