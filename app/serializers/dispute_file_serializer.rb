class DisputeFileSerializer < ActiveModel::Serializer
  attributes :id, :upload_url, :key, :filename

  def key
    object.filename
  end

  def filename
    File.basename(object.filename)
  end
end
