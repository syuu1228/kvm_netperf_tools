#!/usr/bin/ruby
require 'yaml'
require "#{File.dirname(__FILE__)}/lib/array_extender.rb"

if ARGV.size < 1
	puts "format_netperf2.rb [interface]"
	exit 1
end

IF = ARGV[0]
c = YAML.load_file("#{File.dirname(__FILE__)}/config.yml")
ENTRIES = 2
HEADER = ",lat,tps\n"

nbias = File.new("netperf_#{IF}_nbias.csv", 'w')
nbias.write HEADER

c['cpus'].each do |cpu|
	c['vms'].each do |v|
		max_flows = c['max_flows']
		flow_per_node = max_flows / v

		lat_log = File.new("netperf_lat.#{IF}#{v}-#{cpu}.log", 'r')
		tps_log = File.new("netperf_tps.#{IF}#{v}-#{cpu}.log", 'r')
		node_log = File.new("netperf_node.#{IF}#{v}-#{cpu}.csv", 'w')
		node_log.write "lat,tps\n"

		lat_all = []
		tps_all = []
		(0 ... v).each do |j|
			lat_node = []
			tps_node = []
			(0 ... flow_per_node).each do |f|
				lat_node << lat_log.gets.to_f
				tps_node << tps_log.gets.to_f
			end
			lat_all << lat_node.avg
			tps_all << tps_node.avg
			node_log.write "#{lat_node.avg},#{tps_node.avg}\n"
		end
		node_log.close
		nbias.write "#{IF}#{v}-cpu#{cpu},#{lat_all.bias},#{tps_all.bias}\n"
	end
end
nbias.close
