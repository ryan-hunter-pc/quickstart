# RH Productions Rails Application Template

This is a Rails application template, intended to be used with `rails new`,
according to the recommendations documented in the
[Rails Guides](https://guides.rubyonrails.org/rails_application_templates.html).

It assumes and installs the specific tools and configuration used by RH Productions.

This was inspired by Chris Oliver's [jumpstart](https://github.com/excid3/jumpstart).

## Requirements

This template requires the following installed on your system:

- Ruby 2.6.5
- Bundler `gem install bundler`
- Rails 6.0.2 `gem install rails`
- Postgresql 9.5+
- Yarn - `brew install yarn` or [Install Yarn](https://yarnpkg.com/en/docs/install#debian-stable)

## Usage

### Create a new app
    git clone git@github.com:ryan-hunter-pc/jumpstart.git
    rails new myapp -T -d=postgresql -m ./jumpstart/template.rb
    cd myapp
    
### Run the setup script to setup a local development environment

This can also be done on new machines after cloning the app (rather than generating it, like above).

    bin/setup

### Required Environment Variables

- `DOMAIN` - The domain for use in email links that link back to your environment
- `COOKIE_DOMAIN` - This is only required in production, and **must be omitted in development**
- `MAILER_SENDER` - The default "from" address for transactional emails

### Static Pages

To add static page(s), simply create a page view such as `app/views/pages/my_page.html.erb`,
and it will automatically be wired up to the `/my_page` route.

This functionality uses the [HighVoltage](https://github.com/thoughtbot/high_voltage) gem,
configured for top-level routes via a `PagesController` which uses the view file as the `id` for the `show` action.

---

## TODO

- `marketing` pack(s)? (`app/javascript/stylesheets/marketing.scss` and `app/javascript/packs/marketing.js`)
- MoneyRails
