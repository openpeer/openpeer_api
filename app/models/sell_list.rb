class SellList < List
  validates :payment_methods, presence: true
end
