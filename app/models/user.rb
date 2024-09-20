# app/models/user.rb
class User < ApplicationRecord
  before_validation :set_random_name, on: :create
  before_validation :generate_unique_identifier, on: :create

  validates :address, presence: true, uniqueness: { case_sensitive: false }
  validates :email, 'valid_email_2/email': true, allow_blank: true
  validates :name, uniqueness: { case_sensitive: false }, allow_blank: true, length: { maximum: 15 }
  validates :timezone, inclusion: { in: ActiveSupport::TimeZone.all.map { |tz| tz.tzinfo.name } }, allow_blank: true
  validates :available_from,
    numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 23 }, allow_blank: true
  validates :available_to,
    numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 23 }, allow_blank: true
  validates :telegram_user_id, uniqueness: true, allow_nil: true
  validates :telegram_username, uniqueness: true, allow_nil: true, allow_blank: true
  validates :whatsapp_country_code, presence: true, if: -> { whatsapp_number.present? }
  validates :whatsapp_number, presence: true, if: -> { whatsapp_country_code.present? }

  before_create do
    self.address = Eth::Address.new(self.address).checksummed
  end

  has_many :contracts

    # Trusted users
    has_many :trusted_relationships, dependent: :destroy
    has_many :trusted_users, through: :trusted_relationships
  
    has_many :inverse_trusted_relationships, class_name: "TrustedRelationship", foreign_key: "trusted_user_id"
    has_many :trusting_users, through: :inverse_trusted_relationships, source: :user
  
    # Blocked users
    has_many :blocked_relationships, dependent: :destroy
    has_many :blocked_users, through: :blocked_relationships
  
    has_many :inverse_blocked_relationships, class_name: "BlockedRelationship", foreign_key: "blocked_user_id"
    has_many :blocking_users, through: :inverse_blocked_relationships, source: :user

    has_many :lists, foreign_key: :seller_id
    has_many :buy_orders, foreign_key: :buyer_id, class_name: 'Order'
    has_many :sell_orders, foreign_key: :seller_id, class_name: 'Order'
    has_many :user_disputes
    has_many :list_payment_methods

  def orders
    Order.left_joins(:list).where('orders.buyer_id = ? OR orders.seller_id = ?', id, id)
  end

  def image_url
    return unless image

    s3 = Aws::S3::Resource.new(
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      region: ENV['AWS_REGION']
    )

    bucket = s3.bucket(ENV['AWS_IMAGES_BUCKET'])
    obj = bucket.object(image)

    obj.presigned_url(:get, expires_in: 3600)
  end

  def online
    if timezone.present? && available_from.present? && available_to.present?
      now = Time.current.in_time_zone(timezone)
      return false if (now.saturday? || now.sunday?) && weekend_offline
      now.hour >= available_from && now.hour < available_to
    end
  end

  def self.find_or_create_by_address(address, email = nil)
    User.where('lower(address) = ?', address.downcase).first ||
      User.create(address: Eth::Address.new(address).checksummed, email: email)
  end

  private

  def generate_unique_identifier
    self.unique_identifier ||= SecureRandom.uuid
  end

  def set_random_name
    loop do
      self.name = sanitize_username(generate_random_name)
      break unless User.exists?(name: name)
    end
  end

  def generate_random_name
    rng = RandomNameGenerator.new(RandomNameGenerator::ROMAN)
    rng.compose(3) # Generates a name with 3 syllables
  end

  def sanitize_username(username)
    sanitized = ActiveSupport::Inflector.transliterate(username)
    sanitized = sanitized.gsub(/[^a-zA-Z0-9_]/, '_')
    sanitized = sanitized[0...11] # Adjust length to accommodate 4 random digits
    sanitized = "#{sanitized}#{rand(1000..9999)}" # Append 4 random digits
    sanitized.empty? ? "user_#{SecureRandom.hex(6)}" : sanitized
  end

  def self.generate_unique_usernames(count)
    usernames = Set.new
    while usernames.size < count
      usernames.add(User.new.send(:sanitize_username, User.new.send(:generate_random_name)))
    end
    usernames.to_a
  end

  def self.next_unique_username
    username = $username_queue.shift
    $username_queue.push(User.new.send(:sanitize_username, User.new.send(:generate_random_name))) if $username_queue.size < 1_000
    username
  end
end