ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    # Example authentication helper (adjust to your application's authentication)
    def sign_in_as(user)
      # This is a placeholder. Actual implementation depends on your auth system.
      # If using session-based auth:
      # post sign_in_url, params: { email: user.email, password: 'password' }
      # For Devise, you might use:
      # include Devise::Test::IntegrationHelpers
      # sign_in user
      # For this project, based on previous tests, it seems to be:
      post sign_in_url, params: { email: user.email, password: 'password' } # Assuming 'password' is a valid password for your fixture
    end
  end
end
