module OperatingSystemsHelper
  def display_operating_system arg
    if arg.nil?
      '??OS??'
    elsif arg.is_a? Device
      display_operating_system(arg.operating_system)
    else
      display = arg.name || '??OS??'
      display += " #{arg.version}" if arg.version
      display
    end
  end
end
