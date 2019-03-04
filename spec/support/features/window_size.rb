# Maximize the window when running non-headless JS tests in the browser
RSpec.configure do |config|
  config.before(:each, js: true, driver: :chrome) do
    Capybara.page.driver.browser.manage.window.maximize
  end
end
