class PagesController < ApplicationController
  include HighVoltage::StaticPage
  skip_before_action :require_login
  # layout 'marketing'
end
