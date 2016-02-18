class OperatingSystemHistory < ActiveRecord::Base
  belongs_to :device
  belongs_to :operating_system
end
