module DevicesHelper
  
  def last_heartbeat_display(device)
    if last = device.heartbeats.last
      last
    else
      '-'
    end
  end
  
end
