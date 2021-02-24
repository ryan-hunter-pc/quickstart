#!/usr/bin/env sh

# remove previously generated test app
if [ -d "./testapp" ]; then
  cd testapp
  spring stop
  bundle exec rails db:drop
  cd ..
  rm -rf testapp
fi

# generate test app from local source
rails new testapp --skip-turbolinks --skip-test --skip-sprockets -d=postgresql -m ./template.rb

# setup and development server
cd testapp
bin/setup

# run tests
# bundle exec rspec -f d

# spin up dev server at http://localhost:5000
foreman start -f Procfile.dev
