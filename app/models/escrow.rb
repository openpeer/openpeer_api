class Escrow < ApplicationRecord
  include ExplorerLinks

  belongs_to :order

  def tx_link
    "#{explorer}/tx/#{tx}"
  end

  def chain_id
    order.chain_id
  end
end
