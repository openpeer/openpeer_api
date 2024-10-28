# app/services/talkjs/dry_run_sync_service.rb
class Talkjs::DryRunSyncService
  def initialize(limit: 5)
    @limit = limit
    @app_id = ENV.fetch('TALKJS_APP_ID', 'APP_ID_NOT_SET')
    @total_users = User.count
  end

  def perform_dry_run
    puts "\n=== TalkJS Sync Dry Run ==="
    puts "Total users in database: #{@total_users}"
    puts "Showing sample of #{@limit} users"
    puts "=" * 50

    User.limit(@limit).each do |user|
      puts "\nUser ID: #{user.id}"
      puts "TalkJS Identifier: #{user.unique_identifier}"
      puts "Payload that would be sent to TalkJS:"
      puts JSON.pretty_generate(user_payload(user))
      puts "-" * 50
    end

    puts "\nValidation Summary:"
    validate_requirements

    puts "\nAPI Details:"
    puts "- Endpoint: PUT https://api.talkjs.com/v1/#{@app_id}/users/{user_id}"
    puts "- Batch endpoint: PUT https://api.talkjs.com/v1/#{@app_id}/users"
    puts "- Users will be synced in batches of 100"
    puts "- Estimated API calls needed: #{(@total_users / 100.0).ceil}"
    
    puts "\nNext Steps:"
    puts "1. Run actual sync with: Talkjs::SyncUsersJob.perform_later"
    puts "2. Monitor job progress in your background job dashboard"
  end

  private

  def user_payload(user)
    {
      name: user.name,
      email: [user.email].compact,
      photoUrl: user.image_url,
      role: 'default',
      custom: {
        address: user.address,
        timezone: user.timezone,
        unique_identifier: user.unique_identifier,
        available_from: user.available_from&.to_s,
        available_to: user.available_to&.to_s,
        online: user.online ? 'true' : 'false'
      }.compact
    }.compact
  end

  def validate_requirements
    issues = []
    
    # Check environment variables
    issues << "TALKJS_APP_ID not set" unless ENV['TALKJS_APP_ID'].present?
    issues << "TALKJS_SECRET_KEY not set" unless ENV['TALKJS_SECRET_KEY'].present?

    # Check user data
    sample_users = User.limit(100)
    
    # Check for unique identifiers
    missing_identifiers = sample_users.where(unique_identifier: nil).count
    issues << "#{missing_identifiers} users missing unique_identifier" if missing_identifiers > 0

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
end