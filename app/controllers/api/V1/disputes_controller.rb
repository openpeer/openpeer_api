module Api
  module V1
    class DisputesController < JwtController
      MAX_FILES = 5

      def create
        order = Order.from_user(current_user.address).find_by(uuid: params[:order_id])
        files = Array(params[:files]).take(MAX_FILES)
        if order.present? && files.present?
          dispute = order.dispute || order.build_dispute
          user_dispute = dispute.user_disputes.where(user: current_user).first || dispute.user_disputes.build(user: current_user)
          user_dispute.comments = params[:comments]

          files.each do |file_url|
            user_dispute.dispute_files.build(filename: file_url)
          end

          if user_dispute.save
            order.broadcast
            render json: order, serializer: OrderSerializer, include: '**', status: :ok, root: 'data'
          else
            render json: { data: { success: false, errors: dispute.errors.full_messages }}, status: :unprocessable_entity
          end
        else
          render json:  { data: { success: false, error: 'Invalid order or files' }}, status: :unprocessable_entity
        end
      end
    end
  end
end
