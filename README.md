# RH Productions Rails Application Template

This is a Rails application template, intended to be used with `rails new`,
according to the recommendations documented in the
[Rails Guides](https://guides.rubyonrails.org/rails_application_templates.html).

It assumes the specific tools and stack used by RH Productions,
and asks the user yes/no for optional modules.

This was inspired by Chris Oliver's [jumpstart](https://github.com/excid3/jumpstart).
I originally forked from that, then decided to start over from scratch because
I planned to rewrite most of the template, and just use Chris's patterns for inspiration.

## Requirements

This template requires the following installed on your system:

- Ruby 2.5+
- Bundler `gem install bundler`
- Rails 5.2 `gem install rails`
- Postgresql 9.5+
- Yarn - `brew install yarn` or [Install Yarn](https://yarnpkg.com/en/docs/install#debian-stable)

## Usage

### Create a new app

    rails new myapp -T -d=postgresql --webpack=stimulus -m https://raw.githubusercontent.com/ryan-hunter-pc/jumpstart/master/template.rb
    cd myapp
    
### Run the setup script to setup a local development environment

This can also be done on new machines after cloning the app (rather than generating it, like above).

    bin/setup
