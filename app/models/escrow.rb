class Escrow < ApplicationRecord
  belongs_to :order

  def link
    "#{explorers[order.list.chain_id]}/address/#{address}"
  end

  def tx_link
    "#{explorers[order.list.chain_id]}/tx/#{tx}"
  end

  private

  def explorers
    {
      137 => 'https://polygonscan.com',
      80001 => 'https://mumbai.polygonscan.com'
    }
  end
end
