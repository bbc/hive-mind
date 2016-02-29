module ApplicationHelper
  
  def mini_duration( time )
    wordy_time = distance_of_time_in_words(time, Time.now)
	if wordy_time == "less than a minute"
	  "<1m"
	else
	  wordy_time =~ /(\d+)\s(.)/
	  "#{$1}#{$2}"
	end
  end
  
  def status_label(status)
    "<span class='label label-status label-#{status}'>#{status}</span>".html_safe
  end
  
  
end
