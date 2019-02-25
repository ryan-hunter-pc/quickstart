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
  gem 'colorize'
end

def initialize_git_repository
  git :init
  git add: "."
  git commit: %Q{ -m 'Generate and bundle rails app using ryan-hunter-pc/jumpstart' }
end

def update_setup_script
  gsub_file 'bin/setup', "# system('bin/yarn')", "system('yarn')"
  gsub_file 'bin/setup', "system! 'bin/rails db:setup'", "system! 'bundle exec rails db:setup'"
  comment_lines 'bin/setup', /Restarting application server/
  comment_lines 'bin/setup', /rails restart/
  git add: '.'
  git commit: %Q{ -m "Update setup script" }
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

def copy_example_readme
  remove_file 'README.md'
  copy_file 'example/README.md', 'README.md'
  git add: '.'
  git commit: %Q{ -m "Update README" }
end

def fix_stimulus_compression_issue
  gsub_file 'config/environments/production.rb',
            'config.assets.js_compressor = :uglifier',
            'config.assets.js_compressor = Uglifier.new(harmony: true)'
  git add: '.'
  git commit: %Q{ -m "Fix asset compressor issue with StimulusJS on production" }
end

def setup_stylesheets_plumbing
  insert_into_file 'app/javascript/packs/application.js',
                   "\n// Stylesheets\n",
                   after: "console.log('Hello World from Webpacker')\n"
  insert_into_file 'app/javascript/packs/application.js',
                   "import 'stylesheets/application'\n",
                   after: "// Stylesheets\n"
  create_file 'app/javascript/stylesheets/application.scss', ''
  insert_into_file 'app/views/layouts/application.html.erb',
                   "    <%= stylesheet_pack_tag 'application' %>\n\n",
                   before: /^(.+)stylesheet_link_tag(.+)$/
  git add: '.'
  git commit: %Q{ -m "Setup stylesheets plumbing via webpacker" }
end

def install_tailwind_css
  system 'yarn add tailwindcss'
  system './node_modules/.bin/tailwind init app/javascript/stylesheets/tailwind.js'
  append_to_file '.postcssrc.yml', "  tailwindcss: './app/javascript/stylesheets/tailwind.js'"
  remove_file 'app/javascript/stylesheets/application.scss'
  copy_file 'app/javascript/stylesheets/application.scss'
  directory 'app/javascript/stylesheets/components'
  git add: '.'
  git commit: %Q{ -m "Install Tailwind CSS and some basic SCSS components" }
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


#==========================================================================
# Main Setup Script
#==========================================================================

add_template_repository_to_source_path
add_gems

# TODO: install all the gems

after_bundle do
  initialize_git_repository
  update_setup_script
  # setup_heroku_apps # FIXME: need to finish this method before uncommenting
  copy_example_readme
  fix_stimulus_compression_issue
  setup_stylesheets_plumbing
  install_tailwind_css
  add_visitor_root

  # TODO: setup root route
end