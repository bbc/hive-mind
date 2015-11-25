class DeviceType < ActiveRecord::Base
  
  def device_count
    Device.joins(:model).where(:models=>{:device_type_id => self.id}  ).count
  end
  
end
