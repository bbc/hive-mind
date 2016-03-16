class HiveQueue < ActiveRecord::Base
  has_and_belongs_to_many :devices
end
