class Brand < ActiveRecord::Base
  has_many :models
  
  def device_count
    models.collect{ |m| m.device_count }.sum
  end
end
