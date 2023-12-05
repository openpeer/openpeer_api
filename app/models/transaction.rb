class Transaction < ApplicationRecord
  include ExplorerLinks

  belongs_to :order

  def chain_id
    order.chain_id
  end

  def link
    "#{explorer}/tx/#{tx_hash}"
  end
end
