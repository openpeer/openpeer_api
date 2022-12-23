class User < ApplicationRecord
  validates :address, presence: true, uniqueness: { case_sensitive: false }

  before_create do
    self.address = Eth::Address.new(self.address).checksummed
  end
end
