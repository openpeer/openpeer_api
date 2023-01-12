class User < ApplicationRecord
  validates :address, presence: true, uniqueness: { case_sensitive: false }
  validates :email, 'valid_email_2/email': true, allow_blank: true

  before_create do
    self.address = Eth::Address.new(self.address).checksummed
  end
end
