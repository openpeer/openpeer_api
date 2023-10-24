module Api
  module V1
    class MerchantsController < ApplicationController
      def index
        @merchants = User.where(merchant: true).pluck(:address)
        render json: @merchants, status: :ok, root: 'data'
      end
    end
  end
end
