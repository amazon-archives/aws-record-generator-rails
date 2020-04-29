source "https://rubygems.org"

gemspec

gem 'rake', require: false

group :docs do
  gem 'yard'
  gem 'yard-sitemap', '~> 1.0'
end

group :test do
  gem 'rspec', '~> 3'
  gem 'cucumber'
  gem 'capybara'
  gem 'simplecov', require: false
  gem 'coveralls', require: false if RUBY_VERSION > '1.9.3'
end
