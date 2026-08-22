source "https://rubygems.org"

gem "rails", "~> 8.1.3"

# Asset pipeline
gem "propshaft"

# PostgreSQL database
gem "pg", "~> 1.1"

# Web server
gem "puma", ">= 5.0"

# Authentication
gem "bcrypt", "~> 3.1.7"
gem "jwt"

# JavaScript
gem "importmap-rails"

# Hotwire
gem "turbo-rails"
gem "stimulus-rails"

# JSON APIs
gem "jbuilder"

# Windows timezone data
gem "tzinfo-data", platforms: %i[windows jruby]

# Rails database-backed infrastructure
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Faster boot
gem "bootsnap", require: false

# Deployment
gem "kamal", require: false

# HTTP asset caching/compression
gem "thruster", require: false

# Active Storage image processing
gem "image_processing", "~> 1.2"


group :development, :test do
  # Debugging
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"

  # Security
  gem "bundler-audit", require: false
  gem "brakeman", require: false

  # Code style
  gem "rubocop-rails-omakase", require: false
end


group :development do
  gem "web-console"
end


group :test do
  # System testing
  gem "capybara"
  gem "selenium-webdriver"
end

gem "graphql", "~> 2.6"
gem "graphiql-rails", group: :development
