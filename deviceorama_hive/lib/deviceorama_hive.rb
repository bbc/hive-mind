require "deviceorama_hive/engine"

module DeviceoramaHive
  def self.find_or_create_by options
    Attribute.find_or_create_by(options.permit(:hostname, :ip))
  end
end
