require "device_orama_hive/engine"

module DeviceOramaHive
  def self.find_or_create_by options
    puts options
    Attribute.find_or_create_by(options.permit(:hostname, :ip))
  end
end
