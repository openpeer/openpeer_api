class Token < ApplicationRecord
  validates_uniqueness_of :address, scope: :chain_id, case_sensitive: false
  validates :address, :chain_id, :decimals, :coingecko_id, presence: true

  before_create do
    self.address = Eth::Address.new(self.address).checksummed
  end

  def icon
    "https://raw.githubusercontent.com/ErikThiart/cryptocurrency-icons/master/16/#{coingecko_id}.png"
  end

  def as_json(options)
    super({ methods: [:icon] }.merge(options))
  end
end
