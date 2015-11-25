module HiveMindGeneric
  class Plugin < ActiveRecord::Base
    has_one :device, as: :plugin
    has_many :characteristics

    def name
      "Generic Device #{self.id}"
    end

    def details
      Hash[self.characteristics.map{ |c| [ c.key, c.value ] }]
    end

    def self.plugin_params params
      params
    end

    def self.create(*args)
      # Change all arguments into charactersitics
      args[0] = {
        characteristics: args[0].keys.map { |k|
                           Characteristic.new(key: k, value: args[0][k])
                         }
      } if args[0]

      super(*args)
    end
  end
end
