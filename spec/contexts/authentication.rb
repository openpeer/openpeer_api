RSpec.shared_context 'authentication' do 
  let(:api_user) { FactoryBot.create(:api_user) }

  def authentication_header
    { Authorization: "Token #{api_user.token}"}
  end
end
