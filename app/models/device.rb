class Device < ActiveRecord::Base
  belongs_to :model
  has_many :macs, dependent: :delete_all
  has_many :ips, dependent: :delete_all
  has_and_belongs_to_many :groups
  belongs_to :plugin, polymorphic: true
  has_many :heartbeats, dependent: :delete_all
  has_many :device_actions
  has_many :operating_system_histories
  
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
    if hb = self.heartbeats.last
      (Time.now - hb.created_at).to_i
    end
  end

  def execute_action
    if ac = self.device_actions.where(executed_at: nil).first
      ac.update(executed_at: Time.now)
    end
    ac
  end

  def add_relation relation, secondary
    Relationship.find_or_create_by(
      primary: self,
      secondary: secondary,
      relation: relation
    )
  end

  def delete_relation relation, secondary
    Relationship.delete_all(
      primary: self,
      secondary: secondary,
      relation: relation
    )
  end

  def plugin_json_keys
    ( self.plugin && self.plugin.methods.include?(:json_keys) ) ? self.plugin.json_keys : []
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

  def set_os options = {}
    os = OperatingSystem.find_or_create_by(name: options[:name], version: options[:version])
    if os != self.operating_system
      self.operating_system_histories.select{ |o| o.end_timestamp == nil }.each do |osh|
puts self.operating_system_histories.last.operating_system.inspect
        osh.end_timestamp = Time.now
        osh.save
      end
      OperatingSystemHistory.create(
        device: self,
        operating_system: os,
        start_timestamp: Time.now
      )
      self.reload
    end
  end

  def operating_system
    self.operating_system_histories.last.operating_system if self.operating_system_histories.count > 0
  end
end
