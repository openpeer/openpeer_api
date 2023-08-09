module Api
  module V1
    class Layer3Controller < ApplicationController
      def index
        @user = User.find_or_create_by_address(params[:address]) rescue nil

        return render json: { message: 'Invalid address' }, status: :not_found unless @user

        if user_completed_tasks?
          render json: { status: 'success' }, status: :ok
        else
          render json: { status: 'failed' }, status: :ok
        end
      end

      private

      def user_completed_tasks?
        @user.email.present? && @user.name.present? &&
          @user.lists.any? && @user.orders.any?
      end
    end
  end
end
