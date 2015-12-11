class Heartbeat < ActiveRecord::Base
  belongs_to :device
  belongs_to :reporting_device, class_name: Device
end
