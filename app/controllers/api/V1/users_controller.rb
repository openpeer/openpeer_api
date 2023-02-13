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

      def update
        if JSON.parse(params[:user].to_json) == JSON.parse(params[:message])
          if (Eth::Signature.verify(params[:message], params[:data], params[:address]) rescue false)
            @user = User.where('lower(users.address) = ?', params[:id].downcase).first
            if @user.update(user_params)
              render json: @user, serializer: UserSerializer, status: :ok
            else
              render json: { message: 'User not created', errors: @user.errors }, status: :ok
            end
          end
        end
      end

      protected

      def user_params
        params.require(:user).permit(:id, :email)
      end
    end
  end
end
