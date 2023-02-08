class Order < ApplicationRecord
  enum status: [:created, :escrowed, :release, :cancelled, :dispute, :closed]

  belongs_to :list
  belongs_to :buyer, class_name: 'User'
  has_one :escrow

  scope :from_user, ->(address) do
    joins(list: [:seller]).joins(:buyer)
      .where('lower(users.address) = ? OR lower(buyers_orders.address) = ?', address.downcase, address.downcase)
  end

  before_create do
    if !self.uuid
      self.uuid = Uuid.generate

      while(Order.where(uuid: uuid).any?)
        self.uuid = Uuid.generate
      end
    end
  end
end
