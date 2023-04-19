class SellList < List
  validates :payment_method, presence: true
end
