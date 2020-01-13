class MarketingController < ApplicationController
  skip_before_action :require_login

  def index
    redirect_to dashboard_path if signed_in?
  end
end
