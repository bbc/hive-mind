class Model < ActiveRecord::Base
  belongs_to :brand
  belongs_to :device_type
  has_many :devices
  
  def best_name
    !display_name || display_name.empty? ? name : display_name
  end
  
  def all_groups
    devices.collect { |d| d.groups }.flatten.uniq
  end
  
  def device_count
    devices.count
  end
end
