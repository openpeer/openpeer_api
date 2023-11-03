class Contract < ApplicationRecord
  include ExplorerLinks

  belongs_to :user

  def link
    "#{explorers[chain_id]}/address/#{address}"
  end
end
