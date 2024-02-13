require 'rest-client'

module Blast
  class NewEscrowEventWorker
    include Sidekiq::Worker
    attr_accessor :order

    ESCROW_CREATED = 'EscrowCreated'
    RELEASE = 'Released'
    MARK_AS_PAID = 'SellerCancelDisabled'
    BUYER_CANCEL = 'CancelledByBuyer'
    SELLER_CANCEL = 'CancelledBySeller'
    OPEN_DISPUTE = 'DisputeOpened'
    DISPUTE_RESOLVED = 'DisputeResolved'

    def perform(json)
      json = JSON.parse(json)

      webhook = OpenStruct.new(json)
      return unless webhook.isLive

      event = OpenStruct.new(webhook.event)
      transaction = OpenStruct.new(webhook.transaction)
      chain_id = transaction.chainId || Blast::CHAIN_ID
      trade_id = event.args['_orderHash']

      @order = Order.includes(:list)
                    .find_by(trade_id: trade_id, chain_id: chain_id)
      return unless @order

      contract = Contract.where(chain_id: chain_id)
                         .where('lower(address) = ?', event.address.downcase).first ||
                 Contract.create(chain_id: chain_id, address: Eth::Address.new(event.address).checksummed,
                                 user_id: order.seller_id, version: Setting['contract_version'])
      return unless contract

      user = User.where('lower(address) = ?', transaction.from.downcase).first
      return unless user

      tx_hash = transaction.transactionHash
      return if order.transactions.where(tx_hash: tx_hash).any?

      dispute = order.dispute
      buyer_action = user.id == order.buyer_id

      case event.name
      when ESCROW_CREATED
        Order.transaction do
          order.update(status: :escrowed)
          order.create_escrow(tx: tx_hash, address: contract.address)
        end

        NotificationWorker.perform_async(NotificationWorker::SELLER_ESCROWED, order.id)
      when MARK_AS_PAID
        order.update(status: :release)
        NotificationWorker.perform_async(NotificationWorker::BUYER_PAID, order.id)
      when BUYER_CANCEL, SELLER_CANCEL
        Order.transaction do
          order.cancel!(user)
          dispute.update(resolved: true, winner: buyer_action ? order.seller : order.buyer) if dispute
        end
      when OPEN_DISPUTE
        Order.transaction do
          order.build_dispute.save
          order.update(status: :dispute)
        end
        NotificationWorker.perform_async(NotificationWorker::DISPUTE_OPENED, order.id)
      when DISPUTE_RESOLVED
        address = event.args['_winner']
        winner = User.where('lower(address) = ?', address.downcase).first

        Order.transaction do
          order.update(status: :closed)
          dispute ||= order.build_dispute
          dispute.resolved = true
          dispute.winner = winner
          dispute.save
        end
        NotificationWorker.perform_async(NotificationWorker::DISPUTE_RESOLVED, order.id)
        ping_discord
      when RELEASE
        Order.transaction do
          order.update(status: :closed)
          dispute.update(resolved: true, winner: order.buyer) if dispute
        end
        NotificationWorker.perform_async(NotificationWorker::SELLER_RELEASED, order.id)
        ping_discord
      end

      order.transactions.create(tx_hash: tx_hash)
      order.broadcast
    end

    private

    def ping_discord
      message = {
        content: "New trade done!🎉 [#{order.uuid}](https://admin.openpeer.xyz/admin/orders/#{order.id})."
      }.to_json

      RestClient.post(ENV['ORDERS_CHANNEL_WEBHOOK_URL'], message, { content_type: :json, accept: :json }) rescue nil
    end
  end
end
