module HiveMindGeneric
  class Characteristic < ActiveRecord::Base
    belongs_to :plugin
  end
end
