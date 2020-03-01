require 'rails_helper'

RSpec.feature 'Visitor sees home page' do
  scenario 'sees the headline' do
    visit root_path

    expect(page).to have_content 'Welcome to the RH Productions Quickstart App'
  end
end
