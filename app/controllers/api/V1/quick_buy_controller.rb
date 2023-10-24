module Api
  module V1
    class QuickBuyController < BaseController
      def index
        @lists = List.active.includes([:seller, :token, :fiat_currency, payment_method: [:user, :bank]])
                     .where(total_amount_condition).where(total_fiat_condition)
                     .where(chain_id_condition)
                     .where(token: { symbol: params[:token_symbol] },
                            type: params[:type], fiat_currency: { code: params[:fiat_currency_code] })

        @lists = @lists.sort_by(&:price)
        render json: @lists, each_serializer: ListSerializer, include: "**", status: :ok, root: 'data'
      end

      private

      def total_amount_condition
        "total_available_amount >= #{params[:token_amount]}" if params[:token_amount].present?
      end

      def total_fiat_condition
        return unless params[:fiat_amount].present?

        token = Token.where(chain_id_condition).where(symbol: params[:token_symbol]).first
        return nil unless token

        amount = params[:fiat_amount].to_f
        token_price = token.price_in_currency(params[:fiat_currency_code])
        <<~SQL.squish
          total_available_amount >= #{amount} / (CASE WHEN margin_type = #{List.margin_types['fixed']}
            THEN margin
            ELSE (#{token_price} + (#{token_price} * margin / 100))
            END
          )
          AND (limit_min <= #{amount} OR limit_min IS NULL)
          AND (limit_max >= #{amount} OR limit_max IS NULL)
        SQL
      end

      def chain_id_condition
        { chain_id: params[:chain_id] } if params[:chain_id].present?
      end
    end
  end
end
