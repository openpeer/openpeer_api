source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.2"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.3"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem "rack-cors"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  gem 'rspec-sidekiq'
end

gem 'dotenv-rails', groups: [:development, :test]
gem 'eth'
gem 'rest-client'
gem 'sidekiq'
gem 'strscan', '3.0.3'
gem 'bullet'
gem 'active_model_serializers', '~> 0.10.0'
gem 'email_address'
gem "valid_email2"
gem 'jwt'
gem 'bcrypt', '~> 3.1.7'
gem 'aws-sdk-s3'
gem 'knockapi'
gem "activeadmin", "~> 2.13"

gem "devise", "~> 4.9"

gem "sprockets-rails", "~> 3.4"

gem "active_admin_theme", "~> 1.1"

gem "sass-rails", "~> 6.0"

gem "cancancan", "~> 3.5"

gem 'kaminari'

gem 'activeadmin_json_editor', '~> 0.0.7'

gem 'sidekiq-scheduler'

## added 7/30
gem 'nio4r', '~> 2.5.9'

## added 8/7
gem 'telegram-bot-ruby'

## 9/10/24
gem 'random_name_generator'

## 10/28/24
gem 'httparty'