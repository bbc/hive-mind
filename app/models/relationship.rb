class Relationship < ActiveRecord::Base
  belongs_to :primary, class_name: Device
  belongs_to :secondary, class_name: Device
end
