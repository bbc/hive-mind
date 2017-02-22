require 'active_support/concern'
require 'logger'

module DeviceStatus
  extend ActiveSupport::Concern

  def status
    # Very basic first implementation of statuses
    last_hb = seconds_since_heartbeat
    if last_hb.nil?   
      :unknown
    elsif last_hb > 600
      in_a_hive? ? :dead : :unknown
    elsif last_hb > 180
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

  def log_state_level
    if max_state != DeviceState.new(state: 'debug')
      [max_state, heartbeat_state].max.state
    else
      Logger::Severity::INFO
    end
  end

  def log_state_label
    if max_state != DeviceState.new(state: 'debug')
      [max_state, heartbeat_state].max.state_label
    else
      'info'
    end
  end

  def heartbeat_state
    last_hb = seconds_since_heartbeat
    if last_hb.nil? || last_hb > 600
      DeviceState.new(state: 'error')
    elsif last_hb > 180
      DeviceState.new(state: 'warn')
    else
      DeviceState.new(state: 'info')
    end
  end

  private
  def max_state
    @max_state ||= self.device_states.max
    @max_state ? @max_state : DeviceState.new(state: 'info')
  end
end
