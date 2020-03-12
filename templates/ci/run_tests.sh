#!/usr/bin/env sh

set -e

# CUSTOMIZE YOUR TEST REQUIREMENTS BELOW

bundle config --delete without &&
  bundle install &&
  bundle exec rake db:create db:migrate RAILS_ENV=test &&
  bundle exec rspec
