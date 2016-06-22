class DeviceStatistic < ActiveRecord::Base
  belongs_to :device

  def value
    case self.format
    when 'integer'
      read_attribute(:value).to_i
    else
      read_attribute(:value)
    end
  end
end
