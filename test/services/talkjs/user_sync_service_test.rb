# test/services/talkjs/user_sync_service_test.rb
require 'test_helper'

class Talkjs::UserSyncServiceTest < ActiveSupport::TestCase
  setup do
    @service = Talkjs::UserSyncService.new
    @user = users(:one)  # Create a fixture/factory for this
  end

  test "syncs single user successfully" do
    response = @service.sync_user(@user)
    assert response.success?
  end

  test "batch syncs users successfully" do
    users = User.limit(3)
    response = @service.batch_sync_users(users)
    assert response.success?
  end
end