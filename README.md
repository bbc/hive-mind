# Device-Orama

## Device Engines

For a device called 'mydevice' create a device engine with:

```
rails plugin new device_orama_mydevice --full --dummy-path=spec/dummy --skip-test-unit
```

Edit `device\_orama\_mydevice/lib/device\_orama\_mydevice.md` to make
`DeviceOramaMydevice` into a class instead of a module. This class must have
the following methods:

| Method      | Description                                    |
|-------------|------------------------------------------------|
| name        | Return a device name                           |

## License

Device-Orama is available to everyone under the terms of the MIT open source licence.
Take a look at the LICENSE file in the code.

Copyright (c) 2015 BBC
