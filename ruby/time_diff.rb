require 'date'

def time_diff(v_start_time, v_end_time)
  start_time = nil
  end_time = nil

  if v_start_time.is_a?(String)
    start_time = DateTime.parse(v_start_time).to_time
    end_time = DateTime.parse(v_end_time).to_time
  elsif v_start_time.is_a?(DateTime)
    start_time = v_start_time.to_time
    end_time = v_end_time.to_time
  elsif v_start_time.is_a?(Time)
    start_time = v_start_time
    end_time = v_end_time
  elsif v_start_time.is_a?(Fixnum)
    start_time = Time.at(v_start_time)
    end_time = Time.at(v_end_time)
  else
    raise "Can only handle {String, Fixnum, DateTime, Time} arguments!"
  end

  seconds_diff = (end_time - start_time).to_i

  days = seconds_diff / 86400 
  seconds_diff -= days * 86400

  hours = seconds_diff / 3600  
  seconds_diff -= hours * 3600

  minutes = seconds_diff / 60
  seconds_diff -= minutes * 60

  seconds = seconds_diff

  "#{days} Days #{hours} Hrs #{minutes} Min #{seconds} Sec"
 end