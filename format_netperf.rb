#!/usr/bin/ruby
require 'yaml'
require "#{File.dirname(__FILE__)}/lib/array_extender.rb"

def cal_bias(min, max, avg)
	bias_min = 1 - (min / avg)
	bias_max = (max / avg) - 1
	(bias_min + bias_max) * 100
end

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
		avg_lat, avg_tps = log.gets.split(/,/).map do |i| i.to_f end
		avg.write "#{IF}#{v}-cpu#{cpu},#{avg_lat},#{avg_tps}\n"
		log = File.new("netperf_min.#{IF}#{v}-#{cpu}.log")
		log.gets
		min_lat, min_tps = log.gets.split(/,/).map do |i| i.to_f end
		min.write "#{IF}#{v}-cpu#{cpu},#{min_lat},#{min_tps}\n"
		log = File.new("netperf_max.#{IF}#{v}-#{cpu}.log")
		log.gets
		max_lat, max_tps = log.gets.split(/,/).map do |i| i.to_f end
		max.write "#{IF}#{v}-cpu#{cpu},#{max_lat},#{max_tps}\n"
		
		bias_lat = cal_bias(min_lat, max_lat, avg_lat)
		bias_tps = cal_bias(min_tps, max_tps, avg_tps)
		bias.write "#{IF}#{v}-cpu#{cpu},#{bias_lat},#{bias_tps}\n"
	end
end
avg.close
min.close
max.close
bias.close
