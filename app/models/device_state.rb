require 'logger'

class DeviceState < ActiveRecord::Base
  belongs_to :device

  validates :state, inclusion: { in: Logger::Severity::DEBUG..Logger::Severity::FATAL }
  validates :device, presence: true

  def state= s
    if s.is_a? String
      begin
        write_attribute(:state, Object.const_get("Logger::Severity::#{s.upcase}"))
      rescue NameError
        write_attribute(:state, nil)
      end
    else
      write_attribute(:state, s)
    end
  end
end
