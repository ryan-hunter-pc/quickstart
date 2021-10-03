Capybara.server = :puma, { Silent: true }

Capybara.configure { |config| config.test_id = 'data-test-id' }

RSpec.configure do |config|
  driver = ENV['DRIVER']&.to_sym || :headless_chrome
  screen_size = ENV['SCREEN_SIZE']&.split(",")&.to_i || [1920, 1080]

  # config.before(:each, type: :system) { driven_by :rack_test }
  config.before(:each, type: :system) { driven_by :selenium, using: driver, screen_size: screen_size }
  config.before(:each, type: :system, head: true) { driven_by :selenium, using: :chrome, screen_size: screen_size }
end

# For running Selenium at a "slower" (more human-like) speed
# Very useful when recording videos of test runs
#
# To use:
#   `DRIVER=chrome SLOW=1 SCREEN_SIZE=1920,1080 bundle exec rspec spec/system`
#
# https://gist.github.com/scmx/c577d20ac6ac39c8e36d63b6591749a8
if ENV['SLOW'].present?
  require 'webdrivers'
  module ::Selenium::WebDriver::Remote
    class Bridge
      alias old_execute execute

      def execute(*args)
        sleep(0.1)
        old_execute(*args)
      end
    end
  end
end
