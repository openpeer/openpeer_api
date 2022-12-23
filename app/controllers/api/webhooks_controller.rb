module Api
  class WebhooksController < ApplicationController
    def index
      render 'ok', status: :ok
    end

    def create
      BlockchainEventWorker.perform_async(params.except(:controller, :action).to_json)
      render 'ok', status: :ok
    end
  end
end
