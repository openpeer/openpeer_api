class Dispute < ApplicationRecord
  belongs_to :order
  belongs_to :winner
end
