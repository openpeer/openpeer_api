RSpec.shared_context 'authentication' do
  let(:api_user) { FactoryBot.create(:api_user) }

  def authentication_header
    { 'X-Access-Token': api_user.token }
  end
end
