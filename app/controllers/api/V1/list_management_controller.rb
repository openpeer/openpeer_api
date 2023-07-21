module Api
  module V1
    class ListManagementController < JwtController
      def create
        if JSON.parse(params[:list].to_json) == JSON.parse(params[:message])
          if (Eth::Signature.verify(params[:message], params[:data], params[:address]) rescue false)
            @list = List.new(list_params)
            @list.seller = current_user
            @list.chain_id = params[:chain_id]

            List.transaction do
              @list.payment_method = create_or_update_payment_method
              if @list.save
                render json: @list, status: :ok, root: 'data'
              else
                render json: { data: { message: 'List not created', errors: @list.errors }}, status: :ok
              end
            end
          end
        end
      end

      def update
        if JSON.parse(params[:list].to_json) == JSON.parse(params[:message])
          if (Eth::Signature.verify(params[:message], params[:data], params[:address]) rescue false)
            @list = List.find_by(id: list_update_params[:id], seller_id: current_user.id)

            List.transaction do
              @list.payment_method = create_or_update_payment_method
              if @list.update(list_update_params)
                render json: @list, status: :ok, root: 'data'
              else
                render json: { data: { message: 'List not updated', errors: @list.errors }}, status: :ok
              end
            end
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
                      :token_id, :fiat_currency_id, :type, :bank_id, :deposit_time_limit)
      end

      def payment_method_params
        params.require(:list)
              .require(:payment_method).permit(:id, :bank_id, values: {})
      end

      def list_update_params
        params.require(:list)
              .permit(:id, :margin_type, :margin, :total_available_amount, :limit_min, :limit_max, :terms, :bank_id,
                      :deposit_time_limit)
      end

      private

      def create_or_update_payment_method
        return if list_params[:type] == 'BuyList'

        if payment_method_params[:id]
          @payment_method = ListPaymentMethod.find(payment_method_params[:id])
          if (@payment_method.user == current_user)
            @payment_method.update(payment_method_params)
          end
        else
          @payment_method = ListPaymentMethod.new(payment_method_params)
          @payment_method.user = current_user
          @payment_method.save
        end
        @payment_method
      end
    end
  end
end
