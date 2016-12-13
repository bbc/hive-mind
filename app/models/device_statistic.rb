class DeviceStatistic < ActiveRecord::Base
  belongs_to :device

  def value
    case self.format
    when 'integer'
      read_attribute(:value).to_i
    when 'timestamp'
      Time.at(read_attribute(:value))
    else
      read_attribute(:value)
    end
  end
end
