# Hive Mind

## Device Engines

For a device called 'mydevice' create a device engine with:

```
rails plugin new hive_mind_mydevice --full --dummy-path=spec/dummy --skip-test-unit
```

Create a new model `Plugin` with at least a `device\_id` integer attribute:

```
cd hive_mind_mydevice
rails generate model plugin device_id:integer <other attributes>
```

Modify the 'Plugin' model as follows:

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

## License

Hive Mind is available to everyone under the terms of the MIT open source licence.
Take a look at the LICENSE file in the code.

Copyright (c) 2015 BBC
