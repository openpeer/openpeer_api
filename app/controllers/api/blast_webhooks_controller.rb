require 'openssl'
require 'base64'

module Api
  class BlastWebhooksController < ActionController::API
    before_action :verify_signature

    def index
      render 'ok', status: :ok
    end

    def create
      Blast::EscrowDeployedWorker.perform_async(request.body.read)
      render 'ok', status: :ok
    end

    def escrows
      Blast::NewEscrowEventWorker.perform_async(request.body.read)
      render 'ok', status: :ok
    end

    private

    def verify_signature
      provided_signature = request.headers['X-Signature']
      return render json: { error: 'Empty signature' }, status: :unauthorized if provided_signature.nil?

      signature_verification_string = "#{request.body.read}.#{request.headers['X-Timestamp']}"
      digest = OpenSSL::Digest.new('sha384')
      correct_signature = OpenSSL::HMAC.digest(digest, ENV['BLAST_WEBHOOKS_SECRET'], signature_verification_string)
      correct_signature_base64 = Base64.strict_encode64(correct_signature)

      if correct_signature_base64 != provided_signature
        return render json: { error: 'Invalid signature' }, status: :unauthorized
      end
    end
  end
end
