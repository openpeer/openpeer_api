module Api
  module V1
    class Layer3Controller < ApplicationController
      before_action :find_user

      def account
        fetch_status(@user.email.present? && @user.name.present?)
      end

      def ad
        fetch_status(@user.lists.any?)
      end

      def ordered
        fetch_status(@user.orders.any?)
      end

      private

      def fetch_status(success)
        if success
          render json: { status: 'success' }, status: :ok
        else
          render json: { status: 'failed' }, status: :ok
        end
      end

      def find_user
        @user = User.find_or_create_by_address(params[:address]) rescue nil

        return render json: { message: 'Invalid address' }, status: :not_found unless @user
      end
    end
  end
end
