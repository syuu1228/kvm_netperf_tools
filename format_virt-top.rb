#!/usr/bin/ruby
require 'yaml'
require "#{File.dirname(__FILE__)}/lib/array_extender.rb"

if ARGV.size < 1
	puts "format_virt-top.rb [interface]"
	exit 1
end

IF = ARGV[0]
c = YAML.load_file("#{File.dirname(__FILE__)}/config.yml")
ENTRIES = 5
HEADER = ",cpu_ns,net_rxby,net_txby,net\n"

sum = File.new("virt-top_#{IF}_sum.csv", 'w')
sum.write HEADER
avg = File.new("virt-top_#{IF}_avg.csv", 'w')
avg.write HEADER
max = File.new("virt-top_#{IF}_max.csv", 'w')
max.write HEADER
min = File.new("virt-top_#{IF}_min.csv", 'w')
min.write HEADER
bias = File.new("virt-top_#{IF}_bias.csv", 'w')
bias.write HEADER
c['cpus'].each do |cpu|
	c['vms'].each do |v|
		cpu_ns = []
		net_rxby = []
		net_txby = []
		
		(0...v).each do |i|
			cpu_ns[i] = []
			net_rxby[i] = []
			net_txby[i] = []
		end
		log = File.new("virt-top.#{IF}#{v}-#{cpu}.log")
		log.gets
		log.gets
		log.each do |l|
			line = l.split(/,/)
			i = 18
			n = 0
			while i < line.size
				cpu_ns[n] << line[i+2].to_i
				net_rxby[n] << line[i+8].to_i
				net_txby[n] << line[i+9].to_i
				i += 10
				n += 1
			end
		end

		sum.write "#{IF}#{v}-cpu#{cpu},#{cpu_ns.twodim_sum_avg},#{net_rxby.twodim_sum_avg},#{net_txby.twodim_sum_avg},#{net_rxby.twodim_sum_avg + net_txby.twodim_sum_avg}\n"
		avg.write "#{IF}#{v}-cpu#{cpu},#{cpu_ns.twodim_avg_avg},#{net_rxby.twodim_avg_avg},#{net_txby.twodim_avg_avg},#{net_rxby.twodim_avg_avg + net_txby.twodim_avg_avg}\n"
		max.write "#{IF}#{v}-cpu#{cpu},#{cpu_ns.twodim_max_avg},#{net_rxby.twodim_max_avg},#{net_txby.twodim_max_avg},#{net_rxby.twodim_max_avg + net_txby.twodim_max_avg}\n"
		min.write "#{IF}#{v}-cpu#{cpu},#{cpu_ns.twodim_min_avg},#{net_rxby.twodim_min_avg},#{net_txby.twodim_min_avg},#{net_rxby.twodim_min_avg + net_txby.twodim_min_avg}\n"
		bias.write "#{IF}#{v}-cpu#{cpu},#{cpu_ns.twodim_bias_avg},#{net_rxby.twodim_bias_avg},#{net_txby.twodim_bias_avg},#{net_rxby.twodim_bias_avg + net_txby.twodim_bias_avg}\n"
	end
end
sum.close
max.close
min.close
bias.close
