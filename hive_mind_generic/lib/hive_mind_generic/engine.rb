module HiveMindGeneric
  class Engine < ::Rails::Engine
    isolate_namespace HiveMindGeneric

    config.generators do |g|
      g.test_framework :rspec
    end

    initializer :append_migrations do |app|
      config.paths['db/migrate'].expanded.each do |expanded_path|
        app.config.paths['db/migrate'] << expanded_path
      end
    end
  end
end
