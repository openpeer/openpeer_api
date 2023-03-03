class UserDisputeSerializer < ActiveModel::Serializer
  attributes :id, :comments

  belongs_to :user
  has_many :dispute_files
end
