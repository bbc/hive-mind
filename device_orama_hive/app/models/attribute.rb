class Attribute < ActiveRecord::Base
  def name
    self.hostname
  end
end
