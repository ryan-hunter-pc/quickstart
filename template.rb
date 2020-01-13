require "fileutils"
require "shellwords"

# Copied from: https://github.com/excid3/jumpstart
# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files.
def add_template_repository_to_source_path
  source_paths.unshift(File.dirname(__FILE__))
end

def add_gems
  replace_file 'templates/Gemfile', 'Gemfile'
end

def add_gems_old
  global_gems_to_add = <<~RUBY
    gem 'colorize'
    gem 'simple_form'
    gem 'clearance'
    gem 'high_voltage', '~> 3.1'
    gem 'administrate'
  RUBY
  insert_into_file 'Gemfile', "\n\n#{global_gems_to_add.chomp}", after: /^(.+)bootsnap(.+)$/

  dev_test_gems_to_add = <<-RUBY
  gem 'rails-controller-testing'
  gem 'rspec-rails', '~> 3.8'
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'pry-stack_explorer'
  gem 'timecop'
  RUBY
  gsub_file 'Gemfile', /^(.+)gem(.+)byebug(.+)$/, dev_test_gems_to_add.chomp

  test_gems_group = <<~RUBY
    group :test do
      gem 'capybara'
      gem 'chromedriver-helper'
      gem 'database_cleaner'
      gem 'selenium-webdriver'
      gem 'shoulda-matchers'
      gem 'simplecov', require: false
    end
  RUBY
  insert_into_file 'Gemfile', "\n\n#{test_gems_group.chomp}", after: /^(.+)timecop(.+)$\s+end/

  dev_gems_to_add = <<-RUBY
  gem 'guard-rspec', require: false
  gem 'rails_real_favicon'
  gem 'spring-commands-rspec'
  gem 'terminal-notifier-guard', require: false
  RUBY
  insert_into_file 'Gemfile', "\n#{dev_gems_to_add.chomp}", after: /^(.+)spring-watcher-listen(.+)$/
end

def create_database
  system "bundle exec rails db:create db:migrate"
end

def initialize_git_repository
  git :init
  git add: "."
  git commit: %Q{ -m 'Generate and bundle rails app using ryan-hunter-pc/jumpstart' }
end

def update_setup_script
  gsub_file 'bin/setup', "# system('bin/yarn')", "system('yarn')"
  gsub_file 'bin/setup', "system! 'bin/rails db:prepare'", "system! 'bundle exec rails db:prepare'"
  comment_lines 'bin/setup', /Restarting application server/
  comment_lines 'bin/setup', /rails restart/
  git add: '.'
  git commit: %Q{ -m "Update setup script" }
end

def copy_example_readme
  replace_file 'templates/README.md', 'README.md'
  git add: '.'
  git commit: %Q{ -m "Update README" }
end

def copy_procfiles
  copy_file 'templates/Procfile', 'Procfile'
  copy_file 'templates/Procfile.dev', 'Procfile.dev'
  git add: '.'
  git commit: %Q{ -m "Setup Procfiles for development (Procfile.dev) and production (Procfile)" }
end


#==============================================================================
# Setup Test Suite
#------------------------------------------------------------------------------

def setup_test_suite
  system "bundle exec rails g rspec:install"
  copy_spec_folder
  copy_guardfile
  # disable_yarn_check_in_development
  git add: '.'
  git commit: %Q{ -m "Setup core TDD and debugging suite using RSpec, Capybara, Guard, and FactoryBot" }
end

def copy_guardfile
  copy_file 'templates/Guardfile', 'Guardfile'
end

def copy_spec_folder
  remove_file 'spec/rails_helper.rb'
  remove_file 'spec/spec_helper.rb'
  directory 'spec'
end

def disable_yarn_check_in_development
  gsub_file 'config/environments/development.rb',
            "config.webpacker.check_yarn_integrity = true",
            "config.webpacker.check_yarn_integrity = false"
end


#==============================================================================
# Setup Heroku Apps
#------------------------------------------------------------------------------

def setup_heroku_apps
  return unless yes?('Would you like to create Heroku staging and production applications now?')
  heroku_app_name = ask('What should we name the Heroku apps? e.g. my-app')

  # TODO: create the Heroku apps

  # Add heroku remotes to the setup script
  heroku_setup_block = <<-RUBY
    if system 'heroku'
      puts "\n== Setting Heroku remotes =="
      system "heroku git:remote -a #{heroku_app_name}-staging -r staging"
      system "heroku git:remote -a #{heroku_app_name}-production -r production"
    end
  RUBY

  insert_into_file "bin/setup", "\n#{heroku_setup_block}", after: "system!('bundle install')\n"
end

def install_ui_toolkit
  install_tailwind_css
  install_fontawesome
  integrate_stylesheets_via_webpacker
  git add: '.'
  git commit: %Q{ -m "Setup custom UI kit using Tailwind CSS and FontAwesome 5 via Webpacker" }
end

def install_tailwind_css
  system 'yarn add tailwindcss'
  # system './node_modules/.bin/tailwind init app/javascript/stylesheets/tailwind.js'
  insert_into_file 'postcss.config.js',
                   "    require('tailwindcss'),\n    require('autoprefixer'),\n",
                   before: /^(.+)postcss-import(.+)$/
end

def install_fontawesome
  system 'yarn add @fortawesome/fontawesome-free'
  copy_file 'app/helpers/font_awesome_helper.rb'
end

def integrate_stylesheets_via_webpacker
  insert_into_file 'app/javascript/packs/application.js',
                   "\n// Stylesheets\n",
                   after: "import \"controllers\"\n"
  insert_into_file 'app/javascript/packs/application.js',
                   "import 'stylesheets/application'\n",
                   after: "// Stylesheets\n"
  insert_into_file 'app/views/layouts/application.html.erb',
                   "    <%= stylesheet_pack_tag 'application' %>\n\n",
                   before: /^(.+)stylesheet_link_tag(.+)$/
  directory 'app/javascript/stylesheets'
end

def add_visitor_root
  copy_file 'app/controllers/marketing_controller.rb'
  copy_file 'app/views/marketing/index.html.erb'
  git add: '.'
  git commit: %Q{ -m "Setup root route to verify application configuration" }
end

def install_stimulus
  system "rails webpacker:install:stimulus"

  # fix asset compression issue with StimulusJS on Heroku
  gsub_file 'config/environments/production.rb',
            'config.assets.js_compressor = :uglifier',
            'config.assets.js_compressor = Uglifier.new(harmony: true)'

  git add: '.'
  git commit: %Q{ -m "Install StimulusJS" }
end

def install_simple_form
  system "bundle exec rails g simple_form:install"

  # configure SimpleForm to use our custom Tailwind CSS components
  replace_file 'config/initializers/simple_form.rb'

  git add: '.'
  git commit: %Q{ -m "Install SimpleForm and configure it to use our Tailwind form styles" }
end


#==============================================================================
# Configure Authentication
#------------------------------------------------------------------------------

def configure_authentication
  install_clearance
  copy_authentication_views
  git add: '.'
  git commit: %Q{ -m "Implement basic user authentication using Clearance" }
end

def install_clearance
  announce 'Installing Clearance'
  system "bundle exec rails generate clearance:install"
  system "bundle exec rails db:migrate"
  # no need to generate routes -- they are included manually in a custom `config/routes.rb` file
  # system "bundle exec rails generate clearance:routes"
  replace_file 'app/controllers/application_controller.rb'
  copy_file 'app/controllers/passwords_controller.rb'
  copy_file 'app/controllers/sessions_controller.rb'
  copy_file 'app/controllers/users_controller.rb'
  replace_file 'config/initializers/clearance.rb'
end

def copy_authentication_views
  copy_file 'app/helpers/navigation_helper.rb'
  replace_file 'app/views/layouts/application.html.erb'
  copy_file 'app/views/layouts/_messages.html.erb'
  copy_file 'app/views/layouts/_top_navigation.html.erb'
  copy_file 'app/views/layouts/_sidebar_navigation.html.erb'
  copy_file 'app/javascript/controllers/sidebar_controller.js'
  copy_file 'app/helpers/button_helper.rb'
  directory 'app/views/sessions'
  directory 'app/views/users'
  directory 'app/views/passwords'
  directory 'app/views/clearance_mailer'
end

def copy_configuration_files
  replace_file 'config/routes.rb'
  replace_file 'config/environments/development.rb'
  replace_file 'config/environments/test.rb'
  copy_file 'templates/.env', '.env'
  git add: '.'
  git commit: %Q{ -m "Update application configuration" }
end

def extract_marketing_layout
  copy_file 'app/views/layouts/marketing.html.erb'
  directory 'app/views/layouts/marketing'
  copy_file 'app/controllers/dashboards_controller.rb'
  directory 'app/views/dashboards'
  git add: '.'
  git commit: %Q{ -m "Give marketing pages their own layout" }
end

def configure_static_pages
  directory 'app/views/pages'
  copy_file 'config/initializers/high_voltage.rb'
  copy_file 'app/controllers/pages_controller.rb'
  # this also depends on custom routes defined in `config/routes.rb`
  git add: '.'
  git commit: %Q{ -m "Use HighVoltage for easy static pages using the marketing layout" }
end

def install_administrate
  system "bundle exec rails generate administrate:install"
  # copy our custom overriding admin layout
  replace_file 'app/controllers/admin/application_controller.rb'
  directory 'app/views/layouts/admin'
  directory 'app/views/admin/application'
  directory 'app/views/fields'
  replace_file 'app/dashboards/user_dashboard.rb'
  git add: '.'
  git commit: %Q{ -m "Install Administrate as an admin dashboard framework" }
end

def integrate_selectize
  # install jQuery and expose as global module(s)
  system "yarn add jquery"
  replace_file 'config/webpack/environment.js'
  # install selectize via yarn/webpacker
  system "yarn add selectize"
  insert_into_file 'app/javascript/packs/application.js',
                   "import 'selectize/dist/js/selectize.js'\n",
                   after: "// Javascript Dependencies\n"
  # integrate selectize via StimulusJS
  copy_file 'app/javascript/controllers/selectize_controller.js'
  git add: '.'
  git commit: %Q{ -m "Install and integrate selectize to handle rich select inputs" }
end

def integrate_choices_js
  system "yarn add choices.js"
  # integrate via StimulusJS
  copy_file 'app/javascript/controllers/choices_controller.js'
  copy_file 'app/inputs/choices_input.rb'
  git add: '.'
  git commit: %Q{ -m "Install and integrate choices.js to handle rich select inputs" }
end

def announce(announcement)
  puts "\n#{'=' * 76}\n#{announcement}\n#{'-' * 76}"
end

def replace_file(source, destination = nil)
  destination = destination || source
  remove_file destination
  copy_file source, destination
end

#==========================================================================
# Main Setup Script
#==========================================================================

add_template_repository_to_source_path
add_gems

after_bundle do
  create_database
  initialize_git_repository
  copy_procfiles
  setup_test_suite
  update_setup_script
  copy_example_readme
  # setup_heroku_apps # FIXME: need to finish this method before uncommenting
  install_stimulus
  install_ui_toolkit
  add_visitor_root
  install_simple_form
  configure_authentication
  copy_configuration_files
  extract_marketing_layout
  configure_static_pages
  install_administrate
  integrate_choices_js
end
