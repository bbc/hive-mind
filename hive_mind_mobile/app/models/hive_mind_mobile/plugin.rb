module HiveMindMobile
  class Plugin < ActiveRecord::Base

    has_attached_file :screenshot, default_url: "#{ENV["ATTACHMENT_PATH_BASE"]}/images/:serial/:filename"
    has_one :device, as: :plugin

    validates_attachment_content_type :screenshot, content_type: /\Aimage/

    attr_accessor :model

    def name
      self.model
    end

    def self.plugin_params params
      params.permit(:imei, :model, :serial)
    end

    def self.identify_existing options
      Plugin.find_by(serial: options[:serial]).device
    end
  end
end
