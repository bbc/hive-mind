$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "device_orama_hive/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "device_orama_hive"
  s.version     = DeviceOramaHive::VERSION
  s.authors     = ["Joe Haig"]
  s.email       = ["joe.haig@bbc.co.uk"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of DeviceOramaHive."
  s.description = "TODO: Description of DeviceOramaHive."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.2.4"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
end
