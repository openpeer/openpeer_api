# scripts/test_username_generation.rb
require_relative '../config/environment'
require 'random_name_generator'

def sanitize_username(username)
  sanitized = ActiveSupport::Inflector.transliterate(username)
  sanitized = sanitized.gsub(/[^a-zA-Z0-9_]/, '_')
  sanitized = sanitized[0...11] # Adjust length to accommodate 4 random digits
  sanitized = "#{sanitized}#{rand(1000..9999)}" # Append 4 random digits
  sanitized.empty? ? "user_#{SecureRandom.hex(6)}" : sanitized
end

# Generate and print 100 example usernames using Roman style
puts "Generated 100 Example Usernames (Roman Style):"
puts "--------------------------------"

rng = RandomNameGenerator.new(RandomNameGenerator::ROMAN)

100.times do |i|
  username = rng.compose(3)
  sanitized_username = sanitize_username(username)
  puts "#{i + 1}. #{sanitized_username}"
end

puts "--------------------------------"