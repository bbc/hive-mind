$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "hive_mind_mobile/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "hive_mind_mobile"
  s.version     = HiveMindMobile::VERSION
  s.authors     = ["Jon Wilson"]
  s.email       = ["jon.wilson01@bbc.co.uk"]
  s.homepage    = "https://github.com/bbc/hive_mind_mobile"
  s.summary     = "Mobile plugin for Hive Mind"
  s.description = "Mobile plugin for Hive Mind (https://github.com/bbc/hive_mind)"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.2.4"
  s.add_runtime_dependency "paperclip", "~> 4.3"
end
