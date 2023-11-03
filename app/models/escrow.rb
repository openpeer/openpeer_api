class Escrow < ApplicationRecord
  include ExplorerLinks

  belongs_to :order

  def tx_hash
    tx
  end
end
