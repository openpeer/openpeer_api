module Api
  module V1
    class ListsController < BaseController
      def index
        status = List.statuses[params[:status]]
        status_condition = { status: status } if status
        chain_id_condition = { chain_id: params[:chain_id] } if params[:chain_id]
        type_condition = { type: params[:type] } if params[:type]
        seller = params[:seller]

        @lists = List.includes([:seller, :token, :fiat_currency, payment_method: [:user, bank: [:fiat_currency]],
                                bank: [:fiat_currency]])
                     .where(status_condition).where(chain_id_condition).where(type_condition)
                     .page(params[:page]).per(params[:per_page])
                     .order(created_at: :desc)

        @lists = @lists.joins(:seller)
                       .where('lower(users.address) = ?', seller.downcase) if seller
        render json: @lists, each_serializer: ListSerializer, include: "**", meta: pagination_dict(@lists),
               status: :ok, root: 'data'
      end

      def create
        if JSON.parse(params[:list].to_json) == JSON.parse(params[:message])
          if (Eth::Signature.verify(params[:message], params[:data], params[:address]) rescue false)
            @user = User.find_or_create_by_address(params[:address])
            @list = List.new(list_params)
            @list.seller = @user
            @list.chain_id = params[:chain_id]

            List.transaction do
              @list.payment_method = create_or_update_payment_method
              if @list.save
                render json: @list, status: :ok, root: 'data'
              else
                render json: { message: 'List not created', errors: @list.errors }, status: :ok
              end
            end
          end
        end
      end

      def show
        @list = List.find(params[:id])
        render json: @list, serializer: ListSerializer, include: "**", status: :ok, root: 'data'
      end

      protected

      def list_params
        params.require(:list)
              .permit(:margin_type, :margin, :total_available_amount, :limit_min, :limit_max, :terms,
                      :token_id, :fiat_currency_id, :type, :bank_id)
      end

      def payment_method_params
        params.require(:list)
              .require(:payment_method).permit(:id, :bank_id, values: {})
      end

      private

      def create_or_update_payment_method
        return if list_params[:type] == 'BuyList'

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

      def pagination_dict(collection)
        {
          current_page: collection.current_page,
          total_pages: collection.total_pages,
          total_count: collection.total_count
        }
      end
    end
  end
end
