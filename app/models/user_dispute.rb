class UserDispute < ApplicationRecord
  belongs_to :dispute
  belongs_to :user

  has_many :dispute_files
end
