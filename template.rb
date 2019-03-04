require "fileutils"
require "shellwords"

# Copied from: https://github.com/excid3/jumpstart
# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
def add_template_repository_to_source_path
  if __FILE__ =~ %r{\Ahttps?://}
    require "tmpdir"
    source_paths.unshift(tempdir = Dir.mktmpdir("jumpstart-"))
    at_exit { FileUtils.remove_entry(tempdir) }
    git clone: [
      "--quiet",
      "https://github.com/ryan-hunter-pc/jumpstart.git",
      tempdir
    ].map(&:shellescape).join(" ")

    if (branch = __FILE__[%r{jumpstart/(.+)/template.rb}, 1])
      Dir.chdir(tempdir) { git checkout: branch }
    end
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

def add_gems
  global_gems_to_add = <<~RUBY
    gem 'colorize'
    gem 'simple_form'
  RUBY
  insert_into_file 'Gemfile', "\n\n#{global_gems_to_add.chomp}", after: /^(.+)bootsnap(.+)$/

  dev_test_gems_to_add = <<-RUBY
  gem 'rails-controller-testing'
  gem 'rspec-rails', '~> 3.8'
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

def initialize_git_repository
  git :init
  git add: "."
  git commit: %Q{ -m 'Generate and bundle rails app using ryan-hunter-pc/jumpstart' }
end

def update_setup_script
  gsub_file 'bin/setup', "# system('bin/yarn')", "system('yarn')"
  gsub_file 'bin/setup', "system! 'bin/rails db:setup'", "system! 'bundle exec rails db:create db:migrate'"
  comment_lines 'bin/setup', /Restarting application server/
  comment_lines 'bin/setup', /rails restart/
  git add: '.'
  git commit: %Q{ -m "Update setup script" }
end

def copy_example_readme
  remove_file 'README.md'
  copy_file 'templates/README.md', 'README.md'
  git add: '.'
  git commit: %Q{ -m "Update README" }
end

def copy_procfiles
  copy_file 'templates/Procfile', 'Procfile'
  copy_file 'templates/Procfile.dev', 'Procfile.dev'
  git add: '.'
  git commit: %Q{ -m "Setup Procfiles for development (Procfile.dev) and production (Procfile)" }
end

def setup_test_suite
  copy_spec_folder
  copy_guardfile
  disable_yarn_check_in_development
  git add: '.'
  git commit: %Q{ -m "Setup core TDD and debugging suite using RSpec, Capybara, Guard, and FactoryBot" }
end

def copy_guardfile
  copy_file 'templates/Guardfile', 'Guardfile'
end

def copy_spec_folder
  directory 'spec'
end

def disable_yarn_check_in_development
  gsub_file 'config/environments/development.rb',
            "config.webpacker.check_yarn_integrity = true",
            "config.webpacker.check_yarn_integrity = false"
end

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
  system './node_modules/.bin/tailwind init app/javascript/stylesheets/tailwind.js'
  insert_into_file 'postcss.config.js',
                   "    require('tailwindcss')('./app/javascript/stylesheets/tailwind.js'),\n",
                   before: /^(.+)postcss-import(.+)$/
end

def install_fontawesome
  system 'yarn add @fortawesome/fontawesome-free'
end

def integrate_stylesheets_via_webpacker
  insert_into_file 'app/javascript/packs/application.js',
                   "\n// Stylesheets\n",
                   after: "console.log('Hello World from Webpacker')\n"
  insert_into_file 'app/javascript/packs/application.js',
                   "import 'stylesheets/application'\n",
                   after: "// Stylesheets\n"
  insert_into_file 'app/views/layouts/application.html.erb',
                   "    <%= stylesheet_pack_tag 'application' %>\n\n",
                   before: /^(.+)stylesheet_link_tag(.+)$/
  directory 'app/javascript/stylesheets'
end

def add_visitor_root
  copy_file 'app/controllers/visitors_controller.rb'
  copy_file 'app/views/visitors/index.html.erb'
  insert_into_file 'config/routes.rb',
                   "  root to: 'visitors#index'",
                   after: "Rails.application.routes.draw do\n"
  git add: '.'
  git commit: %Q{ -m "Setup root route to verify application configuration" }
end

def integrate_javascript_via_webpacker
  insert_into_file 'app/javascript/packs/application.js',
                   "\n// Javascript Dependencies\n\n",
                   after: "import 'stylesheets/application'\n"
  insert_into_file 'app/views/layouts/application.html.erb',
                   "\n\n    <%= javascript_pack_tag 'application' %>",
                   after: /^(.+)javascript_include_tag(.+)$/
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
  remove_file 'config/initializers/simple_form.rb'
  copy_file 'config/initializers/simple_form.rb'

  git add: '.'
  git commit: %Q{ -m "Install SimpleForm and configure it to use our Tailwind form styles" }
end

#==========================================================================
# Main Setup Script
#==========================================================================

add_template_repository_to_source_path
add_gems

after_bundle do
  initialize_git_repository
  copy_procfiles
  setup_test_suite
  update_setup_script
  copy_example_readme
  # setup_heroku_apps # FIXME: need to finish this method before uncommenting
  install_ui_toolkit
  add_visitor_root
  integrate_javascript_via_webpacker
  install_stimulus
  install_simple_form
end
