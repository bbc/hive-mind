module HiveMindHive
  class Engine < ::Rails::Engine
    config.generators do |g|
      g.test_framework      :rspec,        :fixture => false
      g.assets false
      g.helper false
    end

    isolate_namespace HiveMindHive
    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths['db/migrate'].expanded.each do |expanded_path|
          app.config.paths['db/migrate'] << expanded_path
        end
      end
    end

    initializer :assets do |app|
      app.config.assets.precompile += %w( hive_mind_hive.js )
    end
  end
end
