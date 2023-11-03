class Transaction < ApplicationRecord
  include ExplorerLinks

  belongs_to :order
end
