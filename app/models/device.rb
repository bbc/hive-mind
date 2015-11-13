class Device < ActiveRecord::Base
  belongs_to :model
  has_and_belongs_to_many :groups
  has_many :macs
  has_many :ips
  
  accepts_nested_attributes_for :groups

  def mac_addresses
    self.macs.map { |m| m.mac }
  end

  def ip_addresses
    self.ips.map { |i| i.ip }
  end
end
