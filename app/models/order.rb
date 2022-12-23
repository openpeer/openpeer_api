class Order < ApplicationRecord
  enum status: [:created, :cancelled, :dispute, :closed]

  belongs_to :list
  belongs_to :buyer, class_name: 'User'
end
