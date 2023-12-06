require 'digest'

class Order < ApplicationRecord
  include ExplorerLinks
  enum status: [:created, :escrowed, :release, :cancelled, :dispute, :closed]

  belongs_to :list
  belongs_to :seller, class_name: 'User'
  belongs_to :buyer, class_name: 'User'
  belongs_to :cancelled_by, class_name: 'User', optional: true
  belongs_to :payment_method, class_name: 'OrderPaymentMethod'
  has_one :escrow
  has_one :dispute
  has_many :transactions
  has_many :cancellation_reasons, dependent: :destroy

  scope :from_user, ->(address) do
    joins(:buyer, :seller)
      .where('lower(users.address) = ? OR lower(sellers_orders.address) = ?', address.downcase, address.downcase)
  end

  def cancel(user)
    return if escrow.present? || !created?

    cancel!(user)
  end

  def cancel!(user)
    update(status: :cancelled, cancelled_by: user, cancelled_at: Time.now)
    NotificationWorker.perform_async(NotificationWorker::ORDER_CANCELLED, id)
  end

  def broadcast
    if buyer
      ActionCable.server.broadcast("OrdersChannel_#{uuid}_#{buyer.address}",
        ActiveModelSerializers::SerializableResource.new(self, scope: buyer, include: '**', root: 'data').to_json)
    end

    if seller
      ActionCable.server.broadcast("OrdersChannel_#{uuid}_#{seller.address}",
        ActiveModelSerializers::SerializableResource.new(self, scope: seller, include: '**', root: 'data').to_json)
    end
  end

  before_create do
    if !self.uuid
      self.uuid = Uuid.generate

      while(Order.where(uuid: uuid).any?)
        self.uuid = Uuid.generate
      end
      self.trade_id = generate_trade_id
    end
  end

  def can_cancel?
    !cancelled? && !closed?
  end

  def simple_cancel?
    !escrow && created? # no need to cancel in the blockchain
  end

  private

  def generate_trade_id
    if list.tron?
      addresses = [uuid, seller.address, buyer.address, list.token.address].join.downcase
      data = "#{addresses}#{raw_token_amount}"
      Eth::Util.prefix_hex(Digest::SHA256.hexdigest(data))
    else
      seller_address = Eth::Util.bin_to_hex Eth::Util.zpad_hex(seller.address, 0)
      buyer_address = Eth::Util.bin_to_hex Eth::Util.zpad_hex(buyer.address, 0)
      token = Eth::Util.bin_to_hex Eth::Util.zpad_hex(list.token.address, 0)
      addresses = [uuid, seller_address, buyer_address, token].join
      data = "#{addresses}#{Eth::Abi.encode(['uint256'], [raw_token_amount]).unpack("H*")[0]}"
      bytes = [data[2..-1]].pack("H*")
      Eth::Util.prefix_hex(Eth::Util.keccak256(bytes).unpack("H*")[0])
    end
  end

  def raw_token_amount
    (token_amount * 10 ** list.token.decimals).to_i
  end
end
