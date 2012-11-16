#!/usr/bin/ruby
require 'yaml'
require 'scanf'
require "#{File.dirname(__FILE__)}/lib/array_extender.rb"

c = YAML.load_file("#{File.dirname(__FILE__)}/config.yml")
ENTRIES = 2
HEADER = ",lat,tps\n"

avg = File.new("netperf_avg.csv", 'w')
avg.write HEADER
min = File.new("netperf_min.csv", 'w')
min.write HEADER
max = File.new("netperf_max.csv", 'w')
max.write HEADER
c['cpus'].each do |cpu|
	c['vms'].each do |v|
		log = File.new("netperf.#{v}-#{cpu}.log")
		log.gets
		lat_log = File.new("netperf_lat.#{v}-#{cpu}.log", 'w')
		(0...v).each do |i|
			lat_log.write log.gets
		end
		lat_log.close
		log.gets
		log.gets
		tps_log = File.new("netperf_tps.#{v}-#{cpu}.log", 'w')
		(0...v).each do |i|
			tps_log.write log.gets
		end
		tps_log.close
		log.gets
		avg_lat, avg_tps = log.gets.scanf("avg lat:%f tps:%f\n")
		min_lat, min_tps = log.gets.scanf("min lat:%f tps:%f\n")
		max_lat, max_tps = log.gets.scanf("max lat:%f tps:%f\n")
		avg_log = File.new("netperf_avg.#{v}-#{cpu}.log", 'w')
		avg_log.write "lat,tps\n#{avg_lat},#{avg_tps}\n"
		avg_log.close
		min_log = File.new("netperf_min.#{v}-#{cpu}.log", 'w')
		min_log.write "lat,tps\n#{min_lat},#{min_tps}\n"
		min_log.close
		max_log = File.new("netperf_max.#{v}-#{cpu}.log", 'w')
		max_log.write "lat,tps\n#{max_lat},#{max_tps}\n"
		max_log.close

		avg.write "vm#{v}-cpu#{cpu},#{avg_lat},#{avg_tps}\n"
		min.write "vm#{v}-cpu#{cpu},#{min_lat},#{min_tps}\n"
		max.write "vm#{v}-cpu#{cpu},#{max_lat},#{max_tps}\n"
	end
end
avg.close
min.close
max.close
