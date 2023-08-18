class BankSerializer < ActiveModel::Serializer
  attributes :id, :name, :account_info_schema, :color

  attribute :icon do
    if object.image.attached?
      if Rails.env.development?
        Rails.application.routes.url_for(
          controller: 'active_storage/blobs/redirect',
          action: :show,
          signed_id: object.image.signed_id,
          filename: object.image.filename.to_s,
          host: 'localhost:5000'
        )
      else
        object.image.url
      end
    end
  end
end
