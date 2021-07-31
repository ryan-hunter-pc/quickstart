Capybara.server = :puma, { Silent: true }

RSpec.configure do |config|
  config.before(:each, type: :system) { driven_by :rack_test }

  config.before(:each, type: :system, js: true) do
    driven_by :selenium, using: :headless_chrome, screen_size: [1920, 1080]
  end

  config.before(:each, type: :system, js: true, head: true) do
    driven_by :selenium, using: :chrome, screen_size: [1920, 1080]
  end
end
