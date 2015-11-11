# Hive Mind

## Device Engines

For a device called 'mydevice' create a device engine with:

```
rails plugin new hive_mind_mydevice --full --dummy-path=spec/dummy --skip-test-unit
```

Edit `hive\_mind\_mydevice/lib/hive\_mind\_mydevice.rb` to make
`HiveMindMydevice` into a class instead of a module. This class must have
the following methods:

| Method      | Description                                    |
|-------------|------------------------------------------------|
| name        | Return a device name                           |

## License

Hive Mind is available to everyone under the terms of the MIT open source licence.
Take a look at the LICENSE file in the code.

Copyright (c) 2015 BBC
