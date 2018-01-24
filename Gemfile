source 'https://rubygems.org'
ruby '2.3.3'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.0.2'
gem 'puma', '~> 3.0'

# Database
gem 'mysql2', '>= 0.3.18', '< 0.5'

# Template Engine
gem 'slim'
gem 'slim-rails'

# form
gem 'reform'

# Frontend
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'
gem 'coffee-rails', '~> 4.2'

# UI/UX
gem 'bootstrap-sass'
gem 'bourbon'
gem 'font-awesome-rails'
gem 'bootstrap_form'
gem'lazy_high_charts'
gem 'clipboard-rails'


# Service
# levenshtein distance
gem 'levenshtein_ruby', '~>0.1.4'
# diff
gem 'diff-lcs'

# multi Processes
gem 'parallel'

gem 'dotenv'

gem 'kaminari'

gem 'ransack'

gem 'activerecord-import'
gem 'active_hash'

gem 'config'

# soft delete
gem "paranoia", "~> 2.2"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  # debug
  gem 'tapp'
  gem 'bullet'
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'pry-doc'
  gem 'pry-remote'
  gem 'awesome_print'
  gem 'better_errors'
  gem 'binding_of_caller'

  # test
  gem 'rspec'
  gem 'rspec-rails'
  gem 'rspec-power_assert'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'database_cleaner'
  gem 'timecop'

  gem 'annotate'
end
gem 'rails-erd', group: [:development, :test]

group :test do
  gem 'rspec-mocks'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'spring-commands-rspec'
end

group :production do
  # Use Unicorn as the app server
  gem 'unicorn'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
