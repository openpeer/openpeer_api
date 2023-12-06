class Contract < ApplicationRecord
  include ExplorerLinks

  belongs_to :user
end
