require 'active_support/concern'

module DeviceStatus
  extend ActiveSupport::Concern

  def status
    # Very basic first implementation of statuses
    last_hb = seconds_since_heartbeat
    if last_hb.nil?   
      :unknown
    elsif last_hb > 600
      in_a_hive? ? :dead : :unknown
    elsif last_hb > 90
      in_a_hive? ? :unhappy : :unresponsive
    else
      in_a_hive? ? :happy : :visible
    end
  end
  
  def in_a_hive?
    if defined? HiveMindHive
      if !@hive
        @hive = HiveMindHive::Plugin.find_by_connected_device(self)
      end
    end
    !@hive.nil?
  end

end