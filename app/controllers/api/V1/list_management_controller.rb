module Api
  module V1
    class ListManagementController < JwtController
      def index
        @lists = current_user.lists.includes([:seller, :token, :fiat_currency, payment_methods: [:user, :bank]])
                                   .where.not(status: :closed)
        render json: @lists, each_serializer: ListSerializer, include: "**", status: :ok, root: 'data'
      end

      def create
        @list = List.new(list_params)
        @list.seller = current_user

        List.transaction do
          @list.payment_method_ids = create_or_update_payment_methods.map(&:id)

          if @list.save
            render json: @list, status: :ok, root: 'data'
          else
            render json: { data: { message: 'List not created', errors: @list.errors }}, status: :ok
          end
        end
      end

      def update
        @list = List.find_by(id: list_update_params[:id], seller_id: current_user.id)

        List.transaction do
          @list.payment_method_ids = create_or_update_payment_methods.map(&:id)
          if @list.update(list_update_params)
            render json: @list, status: :ok, root: 'data'
          else
            render json: { data: { message: 'List not updated', errors: @list.errors }}, status: :ok
          end
        end
      end

      def destroy
        @list = current_user.lists.find(params[:id])
        @list.update(status: :closed)
        render json: { data: {} }, status: :ok
      end

      protected

      def list_params
        params.require(:list)
              .permit(:margin_type, :margin, :total_available_amount, :limit_min, :limit_max, :terms,
                      :token_id, :fiat_currency_id, :type, :deposit_time_limit, :payment_time_limit,
                      :accept_only_verified, :escrow_type, :chain_id, :bank_ids => [])
      end

      def payment_methods_params
        params.require(:list).permit(payment_methods: [:id, :bank_id, values: {}])
      end

      def list_update_params
        params.require(:list)
              .permit(:id, :margin_type, :margin, :total_available_amount, :limit_min, :limit_max, :terms,
                      :deposit_time_limit, :payment_time_limit, :accept_only_verified, :status, :bank_ids => [])
      end

      private

      def create_or_update_payment_methods
        return [] if list_params[:type] == 'BuyList'

        payment_methods_params[:payment_methods].map do |payment_method_params|
          if payment_method_params[:id]
            payment_method = ListPaymentMethod.find(payment_method_params[:id])
            if (payment_method.user == current_user)
              payment_method.update(payment_method_params)
            end
          else
            payment_method = ListPaymentMethod.new(payment_method_params)
            payment_method.user = current_user
            payment_method.save
          end
          payment_method
        end
      end
    end
  end
end
