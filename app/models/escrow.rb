class Escrow < ApplicationRecord
  belongs_to :order

  def link
    "#{explorers[order.chain_id]}/address/#{address}"
  end

  def tx_link
    "#{explorers[order.chain_id]}/tx/#{tx}"
  end

  private

  def explorers
    {
      137 => 'https://polygonscan.com',
      80001 => 'https://mumbai.polygonscan.com',
      56 => 'https://bscscan.com',
      10 => 'https://optimistic.etherscan.io',
      42161 => 'https://arbiscan.io',
      43114 => 'https://cchain.explorer.avax.network',
      1 => 'https://etherscan.io'
    }
  end
end
