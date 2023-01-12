class UserSerializer < ActiveModel::Serializer
  attributes :id, :address

  attribute :email do
    EmailAddress.munge(object.email) if object.email
  end
end
