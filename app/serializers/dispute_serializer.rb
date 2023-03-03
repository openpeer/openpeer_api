class DisputeSerializer < ActiveModel::Serializer
  attributes :id, :resolved, :user_dispute, :counterpart_replied
  belongs_to :winner

  def user_dispute
    UserDisputeSerializer.new(dispute).attributes if dispute
  end

  def counterpart_replied
    object.user_disputes.count > 1
  end

  private
  def dispute
    @dispute ||= object.user_disputes.find_by(user_id: current_user.id) if current_user
  end

  def current_user
    @instance_options[:scope]
  end
end
