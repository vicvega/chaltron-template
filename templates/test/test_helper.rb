ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# automatically require all helpers in test/test_helpers
Rails.root.glob("test/test_helpers/**/*.rb").each { |f| require f }

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    # fixtures :all

    # Add more helper methods to be used by all tests here...
    include FactoryBot::Syntax::Methods
  end
end

module ActionDispatch
  class IntegrationTest
    include Devise::Test::IntegrationHelpers
  end
end

# Temporary fix devise issue with rails 8
# https://github.com/heartcombo/devise/issues/5705
ActiveSupport.on_load(:action_mailer) do
  Rails.application.reload_routes_unless_loaded
end
