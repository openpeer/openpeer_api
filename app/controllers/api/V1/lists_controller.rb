module Api
  module V1
    class ListsController < BaseController
      def index
        status = List.statuses[params[:status]]
        status_condition = { status: status } if status
        chain_id_condition = { chain_id: params[:chain_id] } if params[:chain_id]
        seller = params[:seller]

        @lists = List.includes(:seller, :token, :fiat_currency).where(status_condition).where(chain_id_condition)
        @lists = @lists.joins(:seller)
                       .where('lower(users.address) = ?', seller.downcase) if seller
        render json:@lists, each_serializer: ListSerializer, include: "**", status: :ok
      end

      def create
        if JSON.parse(params[:list].to_json) == JSON.parse(params[:message])
          if (Eth::Signature.verify(params[:message], params[:data], params[:address]) rescue false)
            @user = User.where('lower(address) = ?', params[:address].downcase).first ||
                    User.create(address: Eth::Address.new(params[:address]).checksummed)
            @list = List.new(list_params)
            @list.seller = @user
            @list.chain_id = params[:chain_id]

            List.transaction do
              @list.payment_method = create_or_update_payment_method
              if @list.save
                render json: @list, status: :ok
              else
                render json: { message: 'List not created', errors: @list.errors }, status: :ok
              end
            end
          end
        end
      end

      protected

      def list_params
        params.require(:list)
              .permit(:margin_type, :margin, :total_available_amount, :limit_min, :limit_max, :terms,
                      :token_id, :fiat_currency_id)
      end

      def payment_method_params
        params.require(:list)
              .require(:payment_method).permit(:id, :account_name, :account_number, :bank_id)
      end

      private

      def create_or_update_payment_method
        if payment_method_params[:id]
          @payment_method = PaymentMethod.find(payment_method_params[:id])
          if (@payment_method.user == @user)
            @payment_method.update(payment_method_params)
          end
        else
          @payment_method = PaymentMethod.new(payment_method_params)
          @payment_method.user = @user
          @payment_method.save
        end
        @payment_method
      end
    end
  end
end
