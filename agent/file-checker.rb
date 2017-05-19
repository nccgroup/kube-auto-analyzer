#!/usr/bin/env ruby

require 'etc'
require 'json'

@directories = ARGV

@results = Array.new

@directories.each do |dir|
  files = Dir.glob(dir + "/**/*")
  files.each do |f|
    begin
      user = Etc.getpwuid(File.stat(f).uid).name
      group = Etc.getgrgid(File.stat(f).gid).name
      permissions = (File.stat(f).mode & 0777).to_s(8)
      @results << [f, user, group, permissions]
      #puts "#{permissions}\t#{user}\t#{group}\t#{f}\n"
      rescue Errno::ENOENT
        #puts "didn't find " + f
      rescue ArgumentError
        #puts "something went wrong with " + f
    end 
  end
end

puts JSON.generate(@results)