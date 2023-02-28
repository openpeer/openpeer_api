class DisputeSerializer < ActiveModel::Serializer
  attributes :id, :seller_comment, :buyer_comment, :resolved

  belongs_to :winner
  has_many :dispute_files
end
