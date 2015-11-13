require "hive_mind_hive/engine"

module HiveMindHive
  def self.find_or_create_by options
    Attribute.find_or_create_by(options.permit(:hostname))
  end
end
