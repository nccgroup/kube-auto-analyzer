#!/usr/bin/env ruby
#Checks in this script based on amicontained by Jessie Frazelle
# https://github.com/jessfraz/amicontained/

require 'cap2'

results = Hash.new


#Runtime will either be Docker or rkt for now kubepods == docker in all likelihood
runtime = File.open('/proc/self/cgroup').read

if runtime =~ "kubepods"
  results['runtime'] = "kubernetes"
else
  results['runtime'] = "unknown"
end

#Host PID Namespace Detection
hostpid = File.open('/proc/1/sched').read

if hostpid =~ '(1,'
  results['hostpid'] = "true"
else
  results['hostpid'] = "false"
end

#AppArmor Profile Detection
apparmor = File.open('/proc/self/attr/current').read

if apparmor.length > 1
  results['apparmor'] = apparmor
else
  results['apparmor'] = "false"
end


#Check the User Namespaces
uid_map = File.open('/proc/self/uid_map').read

if uid_map.length < 1 || uid_map =~ /\s+0\s+0\s+\d+/
  results['uid_map'] = "false"
else
  results['uid_map'] = "true"
end


#Check Capabilities, This will be hacky!
cap_input = File.open('/proc/1/status')

cap_inh = ("capsh --decode=#{(cap_input[/CapInh:\t\d{16}/].split(/\t/)[1])}")
cap_eff = ("capsh --decode=#{(cap_input[/CapEff:\t\d{16}/].split(/\t/)[1])}")
cap_per = ("capsh --decode=#{(cap_input[/CapPer:\t\d{16}/].split(/\t/)[1])}")
cap_bnd = ("capsh --decode=#{(cap_input[/CapBnd:\t\d{16}/].split(/\t/)[1])}")


if cap_inh.to_s == "true"
  results['cap_inh'] = "None"
else
  results['cap_inh'] = cap_inh
end

if cap_eff.to_s == "true"
  results['cap_eff'] = "None"
else
  results['cap_eff'] = cap_eff
end

if cap_per.to_s == "true"
  results['cap_per'] = "None"
else
  results['cap_per'] = cap_per
end

if cap_bnd.to_s == "true"
  results['cap_bnd'] = "None"
else
  results['cap_bnd'] = cap_bnd
end


puts JSON.generate(results)


