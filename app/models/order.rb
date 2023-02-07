class Order < ApplicationRecord
  enum status: [:created, :escrowed, :release, :cancelled, :dispute, :closed]

  belongs_to :list
  belongs_to :buyer, class_name: 'User'
  has_one :escrow

  before_create do
    if !self.uuid
      self.uuid = Uuid.generate

      while(Order.where(uuid: uuid).any?)
        self.uuid = Uuid.generate
      end
    end
  end
end
