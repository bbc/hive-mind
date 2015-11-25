module HiveMindGeneric
  class Plugin < ActiveRecord::Base
    has_one :device, as: :plugin

    def name
      "Generic Device #{self.id}"
    end

    def self.plugin_params params
      params
    end
  end
end
