# scripts/test_username_generation.rb
require_relative '../config/environment'
require 'random_name_generator'

# Generate and print 100 example usernames using Roman style
puts "Generated 100 Example Usernames (Roman Style):"
puts "--------------------------------"

rng = RandomNameGenerator.new(RandomNameGenerator::ROMAN)

100.times do |i|
  username = rng.compose(3)
  sanitized_username = User.new.send(:sanitize_username, username)
  puts "#{i + 1}. #{sanitized_username}"
end

puts "--------------------------------"