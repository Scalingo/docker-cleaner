# frozen_string_literal: true

source "https://rubygems.org"

gem "docker-api"
# Require to remove transition warning of base64 moving out of stdlib in ruby 3.4
gem "base64"

gem "docker-cleaner", path: "."

group :development, :test do
  gem "rubocop", require: false
  gem "rubocop-performance"
  gem "standard"
end
