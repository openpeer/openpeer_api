class FiatCurrency < ApplicationRecord
  validates :code, :name, presence: true

  def icon
    "https://raw.githubusercontent.com/hampusborgos/country-flags/main/png250px/#{country_code.downcase}.png"
  end

  def as_json(options)
    super({ methods: [:icon] }.merge(options))
  end
end
