HighVoltage.configure do |config|
  # Configure the root route to a HighVoltage page
  # config.home_page = 'home'

  # Use top-level routes like `/about` instead of `/pages/about`
  # config.route_drawer = HighVoltage::RouteDrawers::Root

  # Use a custom layout for all HighVoltage routes
  # -> to override for certain pages, override the PagesController (see readme)
  config.layout = 'marketing'

  # Disable HighVoltage routes altogether (i.e. to override manually)
  config.routes = false

  # Use a custom directory for page views (instead of app/views/pages/)
  # config.content_path = 'site/'
end