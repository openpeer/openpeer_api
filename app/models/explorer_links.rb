module ExplorerLinks
  def link
    "#{explorers[order.chain_id]}/address/#{address}"
  end

  def tx_link
    "#{explorers[order.chain_id]}/tx/#{tx_hash}"
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
      1 => 'https://etherscan.io',
      100 => 'https://gnosisscan.io'
    }
  end
end