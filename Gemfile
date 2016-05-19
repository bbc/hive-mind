source 'https://rubygems.org'

##############################################################################
# Add device plugins here
gem 'hive_mind_hive', path: 'hive_mind_hive'
gem 'hive_mind_generic', path: 'hive_mind_generic'
gem 'hive_mind_mobile', path: 'hive_mind_mobile'
##############################################################################
# Do not change anything below this line
##############################################################################
gem 'rails', '5.0.0.rc1'
gem 'railties', '5.0.0.rc1'
# Won't work due to Rack issues
#gem 'thin' #, '~> 1.6'
gem 'sass-rails', '~> 5.0'
gem 'bootstrap-sass', '~> 3.3.5'
gem 'bootstrap_flash_messages', '~> 1.0.1'
gem 'bootstrap-multiselect-rails'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'omniauth'
gem 'ransack'
gem 'paperclip', '~> 4.3'
gem 'd3-rails'
gem 'chamber'

group :development, :test, :integration do
  gem 'sqlite3'
  gem 'pry-byebug'
  gem "rspec-rails", git: "https://github.com/rspec/rspec-rails.git", branch: "master"
  gem "rspec-core", git: "https://github.com/rspec/rspec-core.git", branch: "master"
  gem "rspec-support", git: "https://github.com/rspec/rspec-support.git", branch: "master"
  gem "rspec-expectations", git: "https://github.com/rspec/rspec-expectations.git", branch: "master"
  gem "rspec-mocks", git: "https://github.com/rspec/rspec-mocks.git", branch: "master"
  gem 'rails-controller-testing'
  gem 'timecop'
end

group :development do
  gem 'web-console', '~> 2.0'
  gem 'spring'
end

group :integration do
  gem 'hive_mind_hive', path: 'hive_mind_hive'
  # Added locally so that the required rails version can be changed from '~> 4.2.4' to '>= 4.2.4' 
  gem 'hive_mind_tv', path: 'hive_mind_tv' #git: 'https://github.com/bbc/hive_mind_tv'
end

group :production do
  gem 'aws-sdk', '~> 1.6'
  gem 'mysql2', '~> 0.3.20'
end

