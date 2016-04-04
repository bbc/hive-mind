class DeviceAction < ActiveRecord::Base
  belongs_to :device
  validates :device_id, presence: true
  validates :action_type, presence: true
  validates :body, presence: true
end
