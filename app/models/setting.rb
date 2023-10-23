class Setting < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :value, presence: true

  def self.[](name)
    find_by(name: name)&.value
  end

  def self.[]=(name, value)
    setting = find_or_initialize_by(name: name)
    setting.value = value
    setting.save!
  end
end
