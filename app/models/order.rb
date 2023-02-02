class Order < ApplicationRecord
  enum status: [:created, :escrowed, :release, :cancelled, :dispute, :closed]

  belongs_to :list
  belongs_to :buyer, class_name: 'User'
  has_one :escrow

  before_create do
    if !uuid 
      uuid = Uuid.generate

      while(Order.where(uuid: uuid).any?)
        uuid = Uuid.generate
      end
    end
  end
end
