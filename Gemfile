# frozen_string_literal: true

source 'https://rubygems.org'

ruby '> 3.0'

# server
gem 'puma'
gem 'rack'
gem 'rackup'

# jobs
gem 'sucker_punch'

# framework
gem 'sinatra'
gem 'sinatra-contrib', '~> 4.0'

# internationalization
gem 'sinatra-r18n', '~> 3.0'

group :development do
  gem 'rubocop', '~> 1.64.1'
  gem 'rubocop-performance', '~> 1.21'
  gem 'solargraph', '~> 0.50.0'
end

group :test do
  gem 'rack-test', '~> 2.1'
  gem 'rspec', '~> 3.13'
  gem 'rspec-html-matchers', '~> 0.10.0'
end
