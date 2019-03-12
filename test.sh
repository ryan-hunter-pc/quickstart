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
rails new testapp -T -d=postgresql --webpack -m ./template.rb

# setup and run development server (optional - comment out to skip)
cd testapp
bin/setup
# bundle exec rspec -f d
bundle exec rails db:migrate
foreman start -f Procfile.dev
