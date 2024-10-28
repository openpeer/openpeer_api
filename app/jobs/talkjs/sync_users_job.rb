# app/jobs/talkjs/sync_users_job.rb
class Talkjs::SyncUsersJob < ApplicationJob
  queue_as :default
  
  def perform(user_ids = nil)
    service = Talkjs::UserSyncService.new
    
    if user_ids
      # Sync specific users
      users = User.where(id: user_ids)
      service.batch_sync_users(users)
    else
      # Sync all users
      service.sync_all_users
    end
  rescue Talkjs::UserSyncService::SyncError => e
    Rails.logger.error("TalkJS sync failed: #{e.message}")
    raise # Re-raise to trigger job retry
  end

  # Retry with exponential backoff
  retry_on Talkjs::UserSyncService::SyncError,
           wait: :exponentially_longer,
           attempts: 5
end