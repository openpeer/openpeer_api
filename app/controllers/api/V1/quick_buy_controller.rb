module Api
  module V1
    class QuickBuyController < BaseController
      def index
        @lists = List.includes([:seller, :token, :fiat_currency, payment_method: [:user, bank: [:fiat_currency]]])
                     .where(total_amount_condition).where(total_fiat_condition)
                     .where(chain_id: params[:chain_id], token: { address: params[:token_address] },
                            type: params[:type], fiat_currency: { code: params[:fiat_currency_code] })

        @lists = @lists.sort_by(&:price)
        render json: @lists, each_serializer: ListSerializer, include: "**", status: :ok
      end

      private

      def total_amount_condition
        "total_available_amount >= #{params[:token_amount]}" if params[:token_amount].present?
      end

      def total_fiat_condition
        return unless params[:fiat_amount].present?

        token = Token.find_by(chain_id: params[:chain_id], address: params[:token_address])
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
    end
  end
end
