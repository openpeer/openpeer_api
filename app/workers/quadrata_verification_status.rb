class QuadrataVerificationStatus
  include Sidekiq::Worker

  def perform(address, chain_id)
    @user = User.find_or_create_by_address(address) rescue nil
    @chain_id = chain_id

    return unless @user && @chain_id
    response = RestClient.get(url, headers)
    verified = JSON.parse(response.body).dig('data').fetch('toClaim', ['all']).empty?
    @user.update(verified: verified)
  end

  private

  def bearer_token
    @bearer_token ||= Quadrata::BearerTokenFetcher.fetch
  end

  def url
    "#{ENV['QUADRATA_API_URL']}/attributes/onboard_status?wallet=#{@user.address}&chainId=#{@chain_id}&attributes=did,aml"
  end

  def headers
    { 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{bearer_token}" }
  end
end
