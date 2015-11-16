module HiveMindHive
  class Plugin < ActiveRecord::Base
    has_one :device, as: :plugin
    def name
      self.hostname
    end

    def self.plugin_params params
      params.permit(:hostname )
    end
  end
end
