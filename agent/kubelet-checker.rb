#!/usr/bin/env ruby

require 'json'
#We are using HTTP Party here as rest-client has a C dependency which would bloat the image a lot.
require 'httparty'

def is_port_open?(ip, port)
  begin
    Socket.tcp(ip, port, connect_timeout: 2)
  rescue Errno::ECONNREFUSED
    return false
  rescue Errno::ETIMEDOUT
    return false
  end
  true
end

targets = ARGV[0].split(',')
results = Hash.new
targets.each do |nod|
  if is_port_open?(nod, 10250)
    
    response = HTTParty.get("https://#{nod}:10250/runningpods", :verify => false)
    
    if response.forbidden?
      results[nod] = "Not Vulnerable - Request Forbidden"
    else
      results[nod] = response.body
    end
  else
    results[nod] = "Not Vulnerable - Port Not Open"
  end
end
puts JSON.generate(results)

