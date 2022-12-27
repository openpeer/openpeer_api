class Bank < ApplicationRecord
  validates :name, presence: true
  belongs_to :fiat_currency, optional: true

  def icon
    "https://raw.githubusercontent.com/hampusborgos/country-flags/main/png250px/#{name.downcase}.png"
  end

  def as_json(options)
    super({ methods: [:icon] }.merge(options))
  end
end
