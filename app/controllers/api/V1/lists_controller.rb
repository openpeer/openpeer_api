# app/controllers/api/V1/lists_controller.rb

module Api
  module V1
    class ListsController < BaseController
      def index
        @lists = List.distinct.joins(:seller, :token, :fiat_currency)
                     .includes(seller: :contracts)
                     .left_joins(:payment_methods, :banks)
                     .where(status: :active)
                     .where(status_condition).where(chain_id_condition).where(type_condition).where(token_condition)
                     .where(currency_condition).where(payment_method_condition).where(amount_condition)
                     .where(fiat_amount_condition)
                     .page(params[:page]).per(params[:per_page])
                     .order(escrow_type: :desc, created_at: :desc)

        @lists = @lists.joins(:seller)
                       .where('lower(users.address) = ?', seller.downcase) if seller
        render json: @lists, each_serializer: ListSerializer, include: "**", meta: pagination_dict(@lists),
               status: :ok, root: 'data'
      end

      def show
        @list = List.find(params[:id])
        render json: @list, serializer: ListSerializer, include: "**", status: :ok, root: 'data'
      end

      private

      def pagination_dict(collection)
        {
          current_page: collection.current_page,
          total_pages: collection.total_pages,
          total_count: collection.total_count
        }
      end

      def status_condition
        status = List.statuses[params[:status]]
        { status: status } if status
      end

      def chain_id_condition
        { chain_id: params[:chain_id] } if params[:chain_id]
      end

      def type_condition
        { type: params[:type] } if params[:type]
      end

      def amount_condition
        ['lists.total_available_amount >= ?', params[:amount].to_f] if params[:amount].to_f > 0
      end

      def currency_condition
        { fiat_currency_id: params[:currency] } if params[:currency]
      end

      def token_condition
        { token_id: params[:token] } if params[:token]
      end

      def payment_method_condition
        if params[:payment_method]
          ['banks.id = ? OR payment_methods.bank_id = ?', params[:payment_method], params[:payment_method]]
        end
      end

      def fiat_amount_condition
        if params[:fiat_amount].to_f > 0
          ['(lists.limit_min <= ? OR limit_min IS NULL) AND (lists.limit_max >= ? OR limit_max IS NULL)',
            params[:fiat_amount].to_f, params[:fiat_amount].to_f]
        end
      end

      def seller
        params[:seller]
      end
    end
  end
end
