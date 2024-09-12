# scripts/generate_unique_identifiers.rb
require 'securerandom'

# Generate and output 10 unique identifiers
10.times do
  unique_identifier = SecureRandom.uuid
  puts unique_identifier
end