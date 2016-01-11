class Device < ActiveRecord::Base
  belongs_to :model
  has_many :macs, dependent: :delete_all
  has_many :ips, dependent: :delete_all
  has_and_belongs_to_many :groups
  belongs_to :plugin, polymorphic: true
  has_many :heartbeats, dependent: :delete_all
  has_many :device_actions
  
  accepts_nested_attributes_for :groups

  def mac_addresses
    self.macs.map { |m| m.mac }
  end

  def ip_addresses
    self.ips.map { |i| i.ip }
  end

  def details
    details = ( self.plugin && self.plugin.methods.include?(:details) ) ? self.plugin.details : {}
    {
      macs: mac_addresses,
      ips: ip_addresses
    }.merge(details)
  end

  def device_type
    self.model and self.model.device_type.classification
  end
  
  def status
    :unknown
  end

  def heartbeat options = {}
    Heartbeat.create(
      device: self,
      reporting_device: (options.has_key?(:reported_by) ? options[:reported_by] : self)
    )
  end

  def seconds_since_heartbeat
    (Time.now - self.heartbeats.last.created_at).to_i if self.heartbeats.length > 0
  end

  def execute_action
    if ac = self.device_actions.where(executed_at: nil).first
      ac.update(executed_at: Time.now)
    end
    ac
  end

  def self.identify_existing options = {}
    if options.has_key?(:device_type)
      begin
        obj = Object.const_get("HiveMind#{options[:device_type].capitalize}::Plugin")
        if obj.methods.include? :identify_existing
          return obj.identify_existing(options)
        end
      rescue NameError
        puts "Unknown device type"
      end
    end

    if options.has_key?(:macs)
      options[:macs].each do |m|
        return Device.find(m.device_id) if m.device_id
      end
    end
    return nil
  end
end
