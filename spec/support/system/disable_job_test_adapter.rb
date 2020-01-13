RSpec.configure do |config|
  config.before(:each, type: :system) do
    (ActiveJob::Base.descendants << ActiveJob::Base).each(&:disable_test_adapter)
  end
end
