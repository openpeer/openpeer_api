# lib/tasks/talkjs.rake

puts "Debug: Environment Variables"
puts "TALKJS_APP_ID: #{ENV['TALKJS_APP_ID']}"
puts "TALKJS_SECRET_KEY: #{ENV['TALKJS_SECRET_KEY'].to_s[0..5]}..." if ENV['TALKJS_SECRET_KEY']

require 'csv'

namespace :talkjs do
  desc "List all TalkJS users"
  task list_users: :environment do
    service = Talkjs::UserService.new
    all_users = []
    next_cursor = nil
    
    puts "Fetching all users from TalkJS..."
    
    begin
      # Prepare CSV file
      timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
      csv_filename = Rails.root.join('tmp', "talkjs_users_#{timestamp}.csv")
      
      CSV.open(csv_filename, 'w') do |csv|
        # Write headers
        csv << ['User ID', 'Name', 'Email', 'Role', 'Created At', 'Custom Fields']
        
        # Fetch all pages
        loop do
          result = service.list_users(starting_after: next_cursor)
          current_page_users = result[:data]
          
          puts "\nProcessing batch of #{current_page_users.length} users..."
          
          current_page_users.each do |user|
            created_at = Time.at(user['createdAt']/1000).utc
            
            # Write to CSV
            csv << [
              user['id'],
              user['name'],
              user['email']&.join(', '),
              user['role'],
              created_at,
              user['custom']&.to_json
            ]
            
            # Display in console
            puts "\nUser ID: #{user['id']}"
            puts "Name: #{user['name']}"
            puts "Email: #{user['email']&.join(', ')}"
            puts "Role: #{user['role']}"
            puts "Created At: #{created_at}"
            puts "Custom Fields: #{user['custom']}"
            puts "-" * 30
          end
          
          all_users.concat(current_page_users)
          
          next_cursor = result[:next_page_cursor]
          break unless next_cursor # Stop if no more pages
          
          puts "Fetching next page..."
        end
      end
      
      puts "\n✅ Total users fetched: #{all_users.length}"
      puts "✅ CSV file generated: #{csv_filename}"
      
    rescue Talkjs::UserService::Error => e
      puts "Error: #{e.message}"
      exit 1
    end
  end

  desc "Show online TalkJS users"
  task online_users: :environment do
    service = Talkjs::UserService.new
    
    puts "Fetching online users from TalkJS..."
    
    begin
      result = service.list_users(is_online: true)
      
      puts "\nOnline Users (showing #{result[:data].length} users):"
      puts "=" * 50
      
      result[:data].each do |user|
        puts "\nUser ID: #{user['id']}"
        puts "Name: #{user['name']}"
        puts "Email: #{user['email']&.join(', ')}"
        puts "-" * 30
      end
      
    rescue Talkjs::UserService::Error => e
      puts "Error: #{e.message}"
      exit 1
    end
  end

  desc "Get details for a specific TalkJS user"
  task :get_user, [:user_id] => :environment do |t, args|
    unless args[:user_id]
      puts "Please provide a user ID:"
      puts "rake talkjs:get_user[user_id]"
      exit 1
    end

    service = Talkjs::UserService.new
    
    begin
      user = service.get_user(args[:user_id])
      
      puts "\nUser Details:"
      puts "=" * 50
      puts "User ID: #{user['id']}"
      puts "Name: #{user['name']}"
      puts "Email: #{user['email']&.join(', ')}"
      puts "Role: #{user['role']}"
      puts "Created At: #{Time.at(user['createdAt']/1000).utc}"
      puts "Custom Fields: #{user['custom']}"
      
    rescue Talkjs::UserService::Error => e
      puts "Error: #{e.message}"
      exit 1
    end
  end

  desc "Perform a dry run of the TalkJS sync to see what would be synced"
  task dry_run: :environment do
    def user_payload(user)
      {
        name: user.name,
        email: [user.email].compact,
        photoUrl: user.image_url,
        role: 'user'
      }.compact
    end

    def validate_requirements
      issues = []
      
      # Check environment variables
      issues << "TALKJS_APP_ID not set" unless ENV['TALKJS_APP_ID'].present?
      issues << "TALKJS_SECRET_KEY not set" unless ENV['TALKJS_SECRET_KEY'].present?
  
      # Check user data
      sample_users = User.limit(100)
      
      # Check for names
      missing_names = sample_users.where(name: nil).count
      issues << "#{missing_names} users missing name" if missing_names > 0
  
      # Validate sample user payload
      if sample_user = User.first
        payload = user_payload(sample_user)
        issues << "Missing required 'name' in payload" unless payload[:name].present?
      else
        issues << "No users found in database"
      end
  
      if issues.any?
        puts "\n⚠️  Potential Issues Found:"
        issues.each { |issue| puts "- #{issue}" }
      else
        puts "\n✅ No issues found - ready to sync"
      end
    end

    # Main dry run logic
    limit = ENV['LIMIT'] ? ENV['LIMIT'].to_i : 5
    app_id = ENV.fetch('TALKJS_APP_ID', 'APP_ID_NOT_SET')
    total_users = User.count

    puts "\n=== TalkJS Sync Dry Run ==="
    puts "Total users in database: #{total_users}"
    puts "Showing sample of #{limit} users"
    puts "=" * 50

    User.limit(limit).each do |user|
      puts "\nUser ID: #{user.id}"
      puts "Payload that would be sent to TalkJS:"
      puts JSON.pretty_generate(user_payload(user))
      puts "-" * 50
    end

    puts "\nValidation Summary:"
    validate_requirements

    puts "\nAPI Details:"
    puts "- Endpoint: PUT https://api.talkjs.com/v1/#{app_id}/users/{user_id}"
    puts "- Batch endpoint: PUT https://api.talkjs.com/v1/#{app_id}/users"
    puts "- Users will be synced in batches of 100"
    puts "- Estimated API calls needed: #{(total_users / 100.0).ceil}"
    
    puts "\nNext Steps:"
    puts "1. Run actual sync with: Talkjs::SyncUsersJob.perform_later"
    puts "2. Monitor job progress in your background job dashboard"
  end

  desc "Perform a live sync with TalkJS for a specified number of users"
  task sync: :environment do
    def user_payload(user)
      {
        name: user.name,
        email: [user.email].compact,
        photoUrl: user.image_url,
        role: 'user'
      }.compact
    end

    def validate_requirements
      issues = []
      
      # Check environment variables
      issues << "TALKJS_APP_ID not set" unless ENV['TALKJS_APP_ID'].present?
      issues << "TALKJS_SECRET_KEY not set" unless ENV['TALKJS_SECRET_KEY'].present?
  
      # Check user data
      sample_users = User.limit(100)
      
      # Check for names
      missing_names = sample_users.where(name: nil).count
      issues << "#{missing_names} users missing name" if missing_names > 0
  
      # Validate sample user payload
      if sample_user = User.first
        payload = user_payload(sample_user)
        issues << "Missing required 'name' in payload" unless payload[:name].present?
      else
        issues << "No users found in database"
      end
  
      if issues.any?
        puts "\n⚠️  Potential Issues Found:"
        issues.each { |issue| puts "- #{issue}" }
        exit 1
      else
        puts "\n✅ No issues found - proceeding with sync"
      end
    end

    limit = ENV['LIMIT'] ? ENV['LIMIT'].to_i : nil
    app_id = ENV.fetch('TALKJS_APP_ID', 'APP_ID_NOT_SET')
    service = Talkjs::UserSyncService.new
    total_users = User.count
    
    puts "\n=== TalkJS Live Sync ==="
    puts "Total users in database: #{total_users}"
    if limit
      puts "Syncing up to #{limit} users..."
    else
      puts "Syncing all users..."
    end
    puts "=" * 50

    puts "\nValidation Summary:"
    validate_requirements

    begin
      # Get users based on limit
      users = limit ? User.limit(limit).to_a : User.all.to_a
      total_selected_users = users.length
      total_batches = (total_selected_users / 100.0).ceil
      current_batch = 1

      puts "\nSync Details:"
      puts "- Using endpoint: PUT https://api.talkjs.com/v1/#{app_id}/users"
      puts "- Batch size: 100"
      puts "- Total batches needed: #{total_batches}"
      puts "=" * 50

      users.each do |user|
        puts "\nProcessing User ID: #{user.id}"
        puts "Payload being sent to TalkJS:"
        puts JSON.pretty_generate(user_payload(user))
        puts "-" * 50
      end

      puts "\nStarting actual sync..."
      users.each_slice(100) do |batch|
        puts "\nProcessing batch #{current_batch} of #{total_batches}..."
        
        _response = service.batch_sync_users(batch)  # Using underscore to indicate intentionally unused variable
        
        puts "✅ Successfully synced batch containing #{batch.length} users"
        batch.each do |user|
          puts "- Synced user #{user.id}: #{user.name}"
        end

        current_batch += 1
      end

      puts "\n✅ Sync completed successfully!"
      puts "Total users synced: #{total_selected_users}"
      
    rescue Talkjs::UserSyncService::SyncError => e
      puts "\n❌ Sync failed!"
      puts "Error: #{e.message}"
      exit 1
    end
  end
end