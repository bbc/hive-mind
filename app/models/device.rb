class Device < ActiveRecord::Base
  belongs_to :model
  has_many :macs
  has_many :ips
  has_and_belongs_to_many :groups
  belongs_to :plugin, polymorphic: true
  
  accepts_nested_attributes_for :groups

  def mac_addresses
    self.macs.map { |m| m.mac }
  end

  def ip_addresses
    self.ips.map { |i| i.ip }
  end

  def device_type
    self.model and self.model.device_type.classification
  end
  
  def status
    :unknown
  end
end
