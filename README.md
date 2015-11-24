# Hive Mind

## Device Engines

For a device called 'mydevice' create a device engine with:

```
rails plugin new hive_mind_mydevice --full --dummy-path=spec/dummy
cd hive_mind_mydevice
```

**Optional:** To use rspec for unit tests see the section below.

Ensure that the tables created for the engine are correctly namespaced by
editing `lib/hive_mind_mydevice/engine.rb`:

```
module HiveMindMydevice
  class Engine < ::Rails::Engine
    isolate_namespace HiveMindMydevice
  end
end
```

Create a new model `Plugin` with relevant attributes:

```
rails generate model plugin <attributes>
```

Modify the `app/model/hive_mind_mydevice/plugin.rb` model:

```
module HiveMindMydevice
  class Plugin < ActiveRecord::Base

    has_one :device, as: :plugin

    def name
      # Method for creating the devices name
      # Required
    end

    def self.plugin_params params
      # Return valid parameters from the input list. For example,
      params.permit(:attribute_one, attribute_two)
    end
  end
end
```

### Using rspec to with engines

To use rspec for unit tests add `--skip-test-unit` to the
`rails plugin new` command so that it is:

```
rails plugin new hive_mind_mydevice --full --dummy-path=spec/dummy --skip-test-unit
```

Then add the following line to the file `hive_mind_mydevice.gemspec`:

```
s.add_development_dependency 'rspec-rails'
```

Edit the `lib/hive_mind_mydevice/engine.rb` file to include rspec:

```
module HiveMindMydevice
  class Engine < ::Rails::Engine
    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
```

Set up rspec with:

```
bundle install
rails generate rails:install
```

Finally, edit the `spec/rails_helper.rb` file to find the environment for the
dummy Rails:

```
require File.expand_path('../dummy/config/environment', __FILE__)
```

## License

Hive Mind is available to everyone under the terms of the MIT open source licence.
Take a look at the LICENSE file in the code.

Copyright (c) 2015 BBC
