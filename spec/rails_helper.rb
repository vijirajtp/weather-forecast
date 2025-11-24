ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'

# Add additional requires below this line. Rails is not loaded until this point!
RSpec.configure do |config|
	config.use_transactional_fixtures = true
	config.infer_spec_type_from_file_location!
	config.filter_rails_from_backtrace!
end