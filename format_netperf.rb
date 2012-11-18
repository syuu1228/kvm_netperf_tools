#!/usr/bin/ruby
require 'yaml'
require "#{File.dirname(__FILE__)}/lib/array_extender.rb"

if ARGV.size < 1
	puts "format_netperf.rb [interface]"
	exit 1
end

IF = ARGV[0]
c = YAML.load_file("#{File.dirname(__FILE__)}/config.yml")
ENTRIES = 2
HEADER = ",lat,tps\n"

avg = File.new("netperf_#{IF}_avg.csv", 'w')
avg.write HEADER
min = File.new("netperf_#{IF}_min.csv", 'w')
min.write HEADER
max = File.new("netperf_#{IF}_max.csv", 'w')
max.write HEADER
bias = File.new("netperf_#{IF}_bias.csv", 'w')
bias.write HEADER
c['cpus'].each do |cpu|
	c['vms'].each do |v|
		log = File.new("netperf_avg.#{IF}#{v}-#{cpu}.log")
		log.gets
		avg.write "#{IF}#{v}-cpu#{cpu},#{log.gets}"
		log = File.new("netperf_min.#{IF}#{v}-#{cpu}.log")
		log.gets
		min_lat, min_tps = log.gets.split(/,/).map do |i| i.to_f end
		min.write "#{IF}#{v}-cpu#{cpu},#{min_lat},#{min_tps}\n"
		log = File.new("netperf_max.#{IF}#{v}-#{cpu}.log")
		log.gets
		max_lat, max_tps = log.gets.split(/,/).map do |i| i.to_f end
		max.write "#{IF}#{v}-cpu#{cpu},#{max_lat},#{max_tps}\n"
		bias.write "#{IF}#{v}-cpu#{cpu},#{max_lat - min_lat},#{max_tps - min_tps}\n"
	end
end
avg.close
min.close
max.close
bias.close
