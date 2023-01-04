class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def as_json(options)
    super({ except: [:created_at, :updated_at] }.merge(options))
  end
end
