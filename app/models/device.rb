class Device < ActiveRecord::Base
  belongs_to :model
  has_and_belongs_to_many :groups
  belongs_to :plugin, polymorphic: true
  
  accepts_nested_attributes_for :groups
end
