module DevicesHelper
  
  def last_heartbeat_display(device)
    if last = device.heartbeats.last
      mini_duration(last.created_at)
    else
      '-'
    end
  end

  def state_span state, message
    "<span class='col-sm-12 label label-".html_safe +
      state_to_bootstrap_label(state) +
      "'>".html_safe +
      message +
      "</span>".html_safe
  end

  def state_name state
    [ 'debug', 'info', 'warn', 'error', 'fatal'][state]
  end
  
  def state_to_bootstrap_label state
    [ 'info', 'success', 'warning', 'danger', 'default'][state]
  end
end
