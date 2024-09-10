require 'csv'
require 'active_support/inflector/transliterate'
require_relative '../config/environment'

MAX_USERNAME_LENGTH = 15

# Check for dry run mode
DRY_RUN = ARGV.include?('--dry-run')

# Method to sanitize username
def sanitize_username(username)
  # Replace accented characters with unaccented versions
  sanitized = ActiveSupport::Inflector.transliterate(username)
  
  # Remove @ if it's at the beginning of the username
  sanitized = sanitized.start_with?('@') ? sanitized[1..-1] : sanitized
  
  # Replace special characters with _
  sanitized = sanitized.gsub(/[@\s.'\-|!$&%#@+]/, '_')
  
  # Remove emojis and other non-standard characters
  sanitized = sanitized.gsub(/[^\p{Alnum}_]/, '')
  
  # Truncate to max length
  sanitized = sanitized[0...MAX_USERNAME_LENGTH]
  
  # Ensure the sanitized username is not empty
  sanitized.empty? ? "user_#{SecureRandom.hex(6)}" : sanitized
end

# Find users with non-standard usernames
users_to_update = User.where("name !~ '^[a-zA-Z0-9_]+$'").limit(6000)

# Update each user with a sanitized username
users_updated = 0
users_skipped = 0

puts "Running in #{DRY_RUN ? 'DRY RUN' : 'LIVE'} mode"

CSV.open("username_update_results.csv", "wb") do |csv|
  csv << ["User ID", "Old Username", "New Username"]

  users_to_update.find_each do |user|
    begin
      new_username = sanitize_username(user.name)

      if DRY_RUN
        csv << [user.id, user.name, new_username]
        puts "Would update user #{user.id} from username '#{user.name}' to '#{new_username}'"
        users_updated += 1
      else
        if User.where(name: new_username).exists?
          new_username = "#{new_username}_#{SecureRandom.hex(3)}"
        end
        user.update!(name: new_username)
        users_updated += 1
        puts "Updated user #{user.id} from username '#{user.name}' to '#{new_username}'"
        csv << [user.id, user.name, new_username]
      end
    rescue ActiveRecord::RecordInvalid => e
      users_skipped += 1
      puts "Error updating user #{user.id}: #{e.message}. Skipping."
      csv << [user.id, user.name, "ERROR: #{e.message}"]
    rescue StandardError => e
      users_skipped += 1
      puts "Unexpected error updating user #{user.id}: #{e.message}. Skipping."
      csv << [user.id, user.name, "ERROR: #{e.message}"]
    end
  end
end

puts "Total users #{DRY_RUN ? 'would be' : ''} updated: #{users_updated}"
puts "Total users skipped: #{users_skipped}"