#!/usr/bin/ruby
require 'yaml'
require "#{File.dirname(__FILE__)}/lib/array_extender.rb"

if ARGV.size < 1
	puts "format_virt-top.rb [interface]"
	exit 1
end

IF = ARGV[0]
c = YAML.load_file("#{File.dirname(__FILE__)}/config.yml")
ENTRIES = 6
HEADER = ",cpu_ns,cpu_percent,net_rxby,net_txby,net\n"

all = File.new("virt-top_#{IF}_all.csv", 'w')
all.write "," + HEADER
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
nbias = File.new("virt-top_#{IF}_nbias.csv", 'w')
nbias.write HEADER
c['cpus'].each do |cpu|
	c['vms'].each do |v|
		cpu_ns = []
		cpu_percent = []
		net_rxby = []
		net_txby = []
		
		(0...v).each do |i|
			cpu_ns[i] = []
			cpu_percent[i] = []
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
				cpu_percent[n] << line[i+3].to_i
				net_rxby[n] << line[i+8].to_i
				net_txby[n] << line[i+9].to_i
				i += 10
				n += 1
			end
		end

		(0...v).each do |i|
			all.write "#{IF}#{v}-cpu#{cpu},#{v},#{cpu_ns[i].avg},#{cpu_percent[i].avg},#{net_rxby[i].avg},#{net_txby[i].avg},#{net_rxby[i].avg + net_txby[i].avg}\n"
		end

		sum.write "#{IF}#{v}-cpu#{cpu},#{cpu_ns.twodim_sum_avg},#{cpu_percent.twodim_sum_avg},#{net_rxby.twodim_sum_avg},#{net_txby.twodim_sum_avg},#{net_rxby.twodim_sum_avg + net_txby.twodim_sum_avg}\n"
		avg.write "#{IF}#{v}-cpu#{cpu},#{cpu_ns.twodim_avg_avg},#{cpu_percent.twodim_avg_avg},#{net_rxby.twodim_avg_avg},#{net_txby.twodim_avg_avg},#{net_rxby.twodim_avg_avg + net_txby.twodim_avg_avg}\n"
		max.write "#{IF}#{v}-cpu#{cpu},#{cpu_ns.twodim_max_avg},#{cpu_percent.twodim_max_avg},#{net_rxby.twodim_max_avg},#{net_txby.twodim_max_avg},#{net_rxby.twodim_max_avg + net_txby.twodim_max_avg}\n"
		min.write "#{IF}#{v}-cpu#{cpu},#{cpu_ns.twodim_min_avg},#{cpu_percent.twodim_min_avg},#{net_rxby.twodim_min_avg},#{net_txby.twodim_min_avg},#{net_rxby.twodim_min_avg + net_txby.twodim_min_avg}\n"
		bias.write "#{IF}#{v}-cpu#{cpu},#{cpu_ns.twodim_bias_avg},#{cpu_percent.twodim_bias_avg},#{net_rxby.twodim_bias_avg},#{net_txby.twodim_bias_avg},#{net_rxby.twodim_bias_avg + net_txby.twodim_bias_avg}\n"
		nbias.write "#{IF}#{v}-cpu#{cpu},#{cpu_ns.twodim_nbias_avg},#{cpu_percent.twodim_nbias_avg},#{net_rxby.twodim_nbias_avg},#{net_txby.twodim_nbias_avg},#{net_rxby.twodim_nbias_avg + net_txby.twodim_nbias_avg}\n"
	end
end
sum.close
max.close
min.close
bias.close
