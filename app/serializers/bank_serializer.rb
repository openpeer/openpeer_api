class BankSerializer < ActiveModel::Serializer
  attributes :id, :name
  
  belongs_to :fiat_currency
  
  attribute :icon do
    "https://raw.githubusercontent.com/ErikThiart/cryptocurrency-icons/master/16/#{object.id}.png"
  end
end
