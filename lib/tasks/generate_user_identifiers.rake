# lib/tasks/generate_user_identifiers.rake
namespace :users do
  desc 'Generate unique identifiers for users without one'
  task generate_identifiers: :environment do
    User.where(unique_identifier: nil).find_each do |user|
      user.send(:generate_unique_identifier)
      user.save!
      puts "User: #{user.name || 'N/A'}, Wallet: #{user.address}, Unique Identifier: #{user.unique_identifier}"
    end
    puts 'Unique identifiers generated for all users.'
  end
end
