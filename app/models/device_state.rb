require 'logger'

class DeviceState < ActiveRecord::Base
  belongs_to :device

  validates :state, inclusion: { in: Logger::Severity::DEBUG..Logger::Severity::FATAL }
  validates :device, presence: true
  validates_lengths_from_database only: [ :message ]

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

  def state_label
    case state
    when Logger::Severity::DEBUG
      'debug'
    when Logger::Severity::INFO
      'info'
    when Logger::Severity::WARN
      'warn'
    when Logger::Severity::ERROR
      'error'
    when Logger::Severity::FATAL
      'fatal'
    else
      'unknown'
    end
  end

  def <=> other
    self.state <=> other.state
  end
end
