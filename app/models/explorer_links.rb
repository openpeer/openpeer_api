module ExplorerLinks
  def link
    "#{explorer}/address/#{address}"
  end

  def network_name
    names[chain_id]
  end

  def explorer
    explorers[chain_id]
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
      100 => 'https://gnosisscan.io',
      168587773 => 'https://testnet.blastscan.io',
      81457 => 'https://blastscan.io',
    }
  end

  def names
    {
      137 => 'Polygon',
      80001 => 'Matic Mumbai',
      56 => 'Binance Smart Chain',
      10 => 'Optimism',
      42161 => 'Arbitrum',
      43114 => 'Avalanche',
      1 => 'Ethereum',
      100 => 'Gnosis',
      168587773 => 'Blast Testnet',
      81457 => 'Blast',
    }
  end
end