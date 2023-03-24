module Api
  class WebhooksController < ActionController::API
    before_action :verify_signature

    def index
      render 'ok', status: :ok
    end

    def create
      EscrowDeployedWorker.perform_async(params.except(:controller, :action).to_json)
      render 'ok', status: :ok
    end

    def escrows
      NewEscrowEventWorker.perform_async(params.except(:controller, :action).to_json)
      render 'ok', status: :ok
    end

    private

    def verify_signature
      provided_signature = request.headers['x-signature']
      return render json: { error: 'Empty signature' }, status: :unauthorized if provided_signature.nil?

      sig = Eth::Util.keccak256(request.body.read + ENV['MORALIS_API_KEY']).unpack("H*")[0]
      generated_signature = Eth::Util.prefix_hex(sig)
      if generated_signature != provided_signature
        return render json: { error: 'Invalid signature' }, status: :unauthorized
      end
    end
  end
end
