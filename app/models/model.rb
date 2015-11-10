class Model < ActiveRecord::Base
  belongs_to :brand
  belongs_to :device_type
  has_many :devices
  
  def all_groups
    devices.collect { |d| d.groups }.flatten.uniq
  end
end
