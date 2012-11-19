#!/usr/bin/ruby
require 'yaml'
require "#{File.dirname(__FILE__)}/lib/array_extender.rb"

c = YAML.load_file("#{File.dirname(__FILE__)}/config.yml")
ENTRIES = 2
HEADER = ",lat,tps\n"

nbias = File.new("netperf_baremetal_nbias.csv", 'w')
nbias.write HEADER
		max_flows = c['max_flows']
		flow_per_node = max_flows

		lat_log = File.new("netperf_lat.baremetal.log", 'r')
		tps_log = File.new("netperf_tps.baremetal.log", 'r')
		node_log = File.new("netperf_node.baremetal.csv", 'w')
		node_log.write "lat,tps\n"

		lat_all = []
		tps_all = []
			lat_node = []
			tps_node = []
			(0 ... flow_per_node).each do |f|
				lat_node << lat_log.gets.to_f
				tps_node << tps_log.gets.to_f
			end
			lat_all << lat_node.avg
			tps_all << tps_node.avg
			node_log.write "#{lat_node.avg},#{tps_node.avg}\n"
		node_log.close
		nbias.write "baremetal,#{lat_all.bias},#{tps_all.bias}\n"
nbias.close
