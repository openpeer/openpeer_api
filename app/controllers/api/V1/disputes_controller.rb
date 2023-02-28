module Api
  module V1
    class DisputesController < JwtController
      MAX_FILES = 5

      def create
        order = Order.from_user(current_user.address).find_by(uuid: params[:order_id])
        files = Array(params[:files]).take(MAX_FILES)
        if order.present? && files.present?
          dispute = order.dispute
          return render json: order, serializer: OrderSerializer, include: '**', status: :ok if dispute 

          dispute_files = []

          files.each do |file_url|
            dispute_files << dispute.dispute_files.build(user: current_user, filename: file_url)
          end

          if dispute.save
            render json: order, serializer: OrderSerializer, include: '**', status: :ok
          else
            render json: { success: false, errors: dispute.errors.full_messages }, status: :unprocessable_entity
          end
        else
          render json: { success: false, error: 'Invalid order or files' }, status: :unprocessable_entity
        end
      end
    end
  end
end
