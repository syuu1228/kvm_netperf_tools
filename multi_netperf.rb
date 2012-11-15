#!/usr/bin/ruby
require 'csv'
require "#{File.dirname(__FILE__)}/array_extender.rb"

if ARGV.size < 6
	puts "multi_netperf.rb [total_flows] [peer_fmt] [start_with] [flow_per_node] [duration] [output_fmt]"
	exit 1
end

flows = ARGV[0].to_i
peer_fmt = ARGV[1]
start_with = ARGV[2].to_i
flow_per_node = ARGV[3].to_i
duration = ARGV[4].to_i
output_fmt = ARGV[5]

c = flow_per_node
v = start_with
(0 ... flows).each do |i|
	Process.fork do
		peer = sprintf(peer_fmt, v)
		exec "netperf -v2 -H #{peer} -t TCP_RR -P 0 -c -C -l #{duration} >> #{sprintf(output_fmt, "raw_#{i}")}"
	end
	c -= 1
	if c == 0
		v +=1
		c = flow_per_node
	end
end
ret = Process.waitall
lat = []
tps = []

(0 ... flows).each do |i|
	log = CSV.open(sprintf(output_fmt, "raw_#{i}"), mode = "r", options = {:col_sep => ' '})
	j = 0
	log.each do |row|
		if j == 5
			lat << row[4].to_f
			tps << row[5].to_f
		end
		j += 1
	end
end

log = File.new(sprintf(output_fmt, 'lat'), 'w')
lat.each do |v|
	log.write "#{v}\n"
end
log.close

log = File.new(sprintf(output_fmt, 'tps'), 'w')
tps.each do |v|
	log.write "#{v}\n"
end
log.close

log = File.new(sprintf(output_fmt, 'avg'), 'w')
log.write "lat,tps\n#{lat.avg},#{tps.avg}\n"
log.close
log = File.new(sprintf(output_fmt, 'max'), 'w')
log.write "lat,tps\n#{lat.max},#{tps.max}\n"
log.close
log = File.new(sprintf(output_fmt, 'min'), 'w')
log.write "lat,tps\n#{lat.min},#{tps.min}\n"
log.close
