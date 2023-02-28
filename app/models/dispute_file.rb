class DisputeFile < ApplicationRecord
  belongs_to :dispute
  belongs_to :user

  def upload_url
    return unless filename

    s3 = Aws::S3::Resource.new(
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      region: ENV['AWS_REGION']
    )

    bucket = s3.bucket(ENV['AWS_IMAGES_BUCKET'])
    obj = bucket.object(filename)

    obj.presigned_url(:get, expires_in: 3600)
  end
end
