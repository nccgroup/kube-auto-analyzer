#!/usr/bin/env ruby

require 'sys/proctable'
require 'json'

cmdlines = Array.new

Sys::ProcTable.ps.each do |process|
  cmdlines << process.cmdline
end

puts JSON.generate(cmdlines)