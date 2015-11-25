module HiveMindGeneric
  class Engine < ::Rails::Engine
    isolate_namespace HiveMindGeneric

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
