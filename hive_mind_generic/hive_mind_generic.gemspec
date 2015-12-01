$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "hive_mind_generic/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "hive_mind_generic"
  s.version     = HiveMindGeneric::VERSION
  s.authors     = ["Joe Haig"]
  s.email       = ["joe.haig@bbc.co.uk"]
  s.homepage    = "http://github.com/bbc/hive_mind"
  s.summary     = "Generic plugin for Hive Mind"
  s.description = "Example plugin for a generic device in Hive Mind"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.4"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
end
