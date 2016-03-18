class Brand < ActiveRecord::Base
  has_many :models
  
  def best_name
    !display_name || display_name.empty? ? name : display_name
  end
  
  def device_count
    models.collect{ |m| m.device_count }.sum
  end
end
