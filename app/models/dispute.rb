class Dispute < ApplicationRecord
  belongs_to :order
  belongs_to :winner, class_name: 'User', optional: true

  has_many :dispute_files
end
