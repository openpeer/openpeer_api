module Api
  class WebhooksController < ApplicationController
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
  end
end
