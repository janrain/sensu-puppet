#!/usr/bin/env ruby
#check_http re-written in Ruby for reasons that made sense at the time

require 'net/http'
require 'uri'
require 'optparse'

$options = {}
usage = "Usage: check_response.rb -H <host> -w <warn threshold> -c <critical threshold>"

optparse = OptionParser.new do|opts|
  opts.banner = usage

  $options[:warn_threshold] = 30.0
  opts.on( '-w', '--warn WARN', Float ) do|warn_threshold|
  	$options[:warn_threshold] = warn_threshold
  end

  $options[:crit_threshold] = 60.0
  opts.on( '-c', '--critical CRIT', Float ) do|crit_threshold|
  	$options[:crit_threshold] = crit_threshold
  end

  $options[:host] = nil
  opts.on( '-H', '--host HOST', String ) do|host|
    $options[:host] = URI.parse(host)
  end
end

optparse.parse!
abort(usage) if ! $options[:host]


def ping(url)
begin
 start_time = Time.now
 response=Net::HTTP.get(url)
 end_time = Time.now - start_time
   if response==""
      return_status="UNKNOWN"
      puts "#{return_status} - response time: #{end_time}"
      exit 3
      return false
   else
     if end_time < $options[:warn_threshold]
      return_status="OK"
      puts "#{return_status} - response time: #{end_time}"
	    exit 0
    elsif end_time >= $options[:warn_threshold] && end_time < $options[:crit_threshold]
      return_status="WARN"
      puts "#{return_status} - response time: #{end_time}"
      exit 1 
    elsif end_time >= $options[:crit_threshold]
      return_status="CRITICAL"
	    puts "#{return_status} - response time: #{end_time}" 
	    exit 2
	end
     return true
   end
   rescue Errno::ECONNREFUSED
      return_status="UNKNOWN"
      puts "#{return_status} - response time: #{end_time}"
      exit 3
      return false
 end
end

ping($options[:host])

