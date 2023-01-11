class User < ApplicationRecord
  validates :address, presence: true, uniqueness: { case_sensitive: false }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  before_create do
    self.address = Eth::Address.new(self.address).checksummed
  end
end
