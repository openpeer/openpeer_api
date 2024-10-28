# app/jobs/talkjs/sync_user_job.rb

module Talkjs
  class SyncUserJob < ApplicationJob
    queue_as :default
    retry_on StandardError, attempts: 3, wait: :exponentially_longer
    
    def perform(user_id)
      user = User.find_by(id: user_id)
      return unless user
      
      service = Talkjs::UserSyncService.new
      service.sync_user(user)
    rescue => e
      Rails.logger.error "Failed to sync user #{user_id} with TalkJS: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      raise e # Re-raise to trigger retry
    end
  end
end