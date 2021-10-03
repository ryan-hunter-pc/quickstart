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

#==============================================================================
# Setup app
#------------------------------------------------------------------------------

def initialize_git_repository
  git :init
  git add: "."
  git commit: %Q{ -m 'Generate and bundle rails app using ryan-hunter-pc/quickstart' }
end

def update_setup_script
  gsub_file 'bin/setup', "bin/rails", "bundle exec rails"
  comment_lines 'bin/setup', /Restarting application server/
  comment_lines 'bin/setup', /rails restart/
  git add: '.'
  git commit: %Q{ -m "Update setup script" }
end

def create_database
  system "bundle exec rails db:prepare"
end

def copy_example_readme
  replace_file 'templates/README.md', 'README.md'
  git add: '.'
  git commit: %Q{ -m "Update README" }
end

def copy_procfiles
  copy_file 'templates/Procfile', 'Procfile'
  copy_file 'templates/Procfile.dev', 'Procfile.dev'
  copy_file 'templates/.foreman', '.foreman'
  git add: '.'
  git commit: %Q{ -m "Setup Procfiles for development (Procfile.dev) and production (Procfile)" }
end


#==============================================================================
# Setup Test Suite
#------------------------------------------------------------------------------

def setup_test_suite
  announce "Installing Test Suite"
  system "bundle exec rails g rspec:install"
  copy_spec_folder
  copy_guardfile
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


#==============================================================================
# UI Toolkit
#------------------------------------------------------------------------------

def merge_javascript_folder_into_packs
  directory 'app/packs/entrypoints', force: true
  remove_dir 'app/javascript/'
end

def integrate_css_via_webpacker
  announce "Installing CSS and PostCSS via Webpacker"

  # mostly following https://dev.to/andrewmcodes/webpacker-6-tutorial-setup-281k
  system 'yarn add file-loader css-loader style-loader mini-css-extract-plugin css-minimizer-webpack-plugin'
  system 'yarn add postcss-loader postcss@latest autoprefixer@latest postcss-import@latest'
  copy_file 'templates/postcss.config.js', 'postcss.config.js'
  replace_file 'config/webpack/base.js'

  # insert_into_file 'app/packs/entrypoints/application.js',
  #                  "\n// Stylesheets\nimport 'stylesheets/application.css'\n"
  insert_into_file 'app/views/layouts/application.html.erb',
                   "    <%= stylesheet_pack_tag 'application' %>\n",
                   after: /^(.+)stylesheet_link_tag(.+)$/
  directory 'app/packs/stylesheets'

  git add: '.'
  git commit: %Q{ -m "Integrate CSS and PostCSS loader for webpacker" }
end

def integrate_images_via_webpacker
  announce "Integrating image assets via webpacker"
  copy_file 'app/packs/images/skier.png'
  # uncomment the lines which enable images via webpacker
  # gsub_file 'app/packs/entrypoints/application.js',
  #           "// const images = require.context('../images', true)",
  #           "const images = require.context('../images', true)"
  # gsub_file 'app/packs/entrypoints/application.js',
  #           "// const imagePath = (name) => images(name, true)",
  #           "const imagePath = (name) => images(name, true)"
  git add: '.'
  git commit: %Q{ -m "Integrate image support for webpacker" }
end

def install_tailwind_css
  announce "Installing Tailwind CSS"
  system 'yarn add tailwindcss @tailwindcss/forms'
  system 'yarn tailwind init'
  insert_into_file 'postcss.config.js',
  "    require('tailwindcss'),\n",
  before: /^(.+)require(.+)autoprefixer(.+)$/

  git add: '.'
  git commit: %Q{ -m "Install Tailwind CSS" }
end

def install_postcss_nesting
  announce "Installing PostCSS Nesting"
  system 'yarn add postcss-nesting'
  insert_into_file 'postcss.config.js',
                   "    require('postcss-nesting'),\n",
                   before: /^(.+)require(.+)autoprefixer(.+)$/
  git add: '.'
  git commit: %Q{ -m "Install postcss-nesting to allow nested CSS" }
end

def install_fontawesome
  announce "Installing FontAwesome"
  system 'yarn add @fortawesome/fontawesome-free'
  # insert_into_file 'app/packs/entrypoints/application.js',
  #                  "\n\nimport '@fortawesome/fontawesome-free/js/all'",
  #                  after: /^import.+regenerator.+runtime.+$/
  git add: '.'
  git commit: %Q{ -m "Install FontAwesome" }
end

#==============================================================================
# Configuration (authentication, layouts, environment config, etc.)
#------------------------------------------------------------------------------

def copy_configuration_files
  replace_file 'config/routes.rb'
  replace_file 'config/environments/development.rb'
  replace_file 'config/environments/test.rb'
  copy_file 'templates/.env', '.env'
  copy_file 'templates/.tool-versions', '.tool-versions'
  replace_file 'config/initializers/dotenv.rb'
  replace_file 'config/initializers/colorize.rb'
  git add: '.'
  git commit: %Q{ -m "Update application configuration" }
end

def configure_authentication
  announce "Installing Authentication using Devise"

  # Install Devise
  generate "devise:install"

  # Copy views into our app so we can customize
  generate "devise:views"

  # Create Devise User
  generate :devise, "User",
           "first_name",
           "last_name",
           "admin:boolean"

  # Set admin default to false
  in_root do
    migration = Dir.glob("db/migrate/*").max_by{ |f| File.mtime(f) }
    gsub_file migration, /:admin/, ":admin, default: false"
  end

  gsub_file "config/initializers/devise.rb",
    /  # config.secret_key = .+/,
    "  config.secret_key = Rails.application.credentials.secret_key_base"

  # Add Devise masqueradable to users
  inject_into_file("app/models/user.rb", "masqueradable, :", after: "devise :")

  git add: '.'
  git commit: %Q{ -m "Implement user authentication using Devise" }
end

def configure_layout
  replace_file 'app/controllers/application_controller.rb'
  copy_file 'app/controllers/marketing_controller.rb'
  copy_file 'app/controllers/dashboards_controller.rb'
  directory 'app/views/layouts', force: true
  directory 'app/views/marketing'
  directory 'app/views/dashboards'

  git add: '.'
  git commit: %Q{ -m "Setup initial application layout and controllers" }
end

def copy_gitignore
  replace_file 'templates/.gitignore', '.gitignore'
  git add: '.'
  git commit: %Q{ -m "Update .gitignore" }
end

#==============================================================================
# Utilities for this template file
#------------------------------------------------------------------------------

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
  # App
  initialize_git_repository
  update_setup_script
  create_database
  copy_procfiles
  copy_example_readme

  # Test suite
  setup_test_suite

  # UI Toolkit
  merge_javascript_folder_into_packs
  integrate_css_via_webpacker
  integrate_images_via_webpacker
  install_tailwind_css
  install_postcss_nesting
  install_fontawesome

  # Configuration, Auth, Admin
  copy_configuration_files
  configure_authentication
  configure_layout
  copy_gitignore

  say
  say "Quickstart app successfully created!", :blue
  say
  say "To get started with your new app:", :green
  say "  cd #{app_name}"
  say "  bin/setup"
  say "  gem install foreman"
  say "  foreman start"
end
