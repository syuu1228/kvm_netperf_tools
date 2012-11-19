#!/usr/bin/ruby
require "#{File.dirname(__FILE__)}/lib/array_extender.rb"

if ARGV.size < 1
	puts "format_virt-top2.rb [log]"
	exit 1
end

puts ",cpu_ns,cpu_percent,net_rxby,net_txby,net\n"

domain_name = []
cpu_ns = []
cpu_percent = []
net_rxby = []
net_txby = []

log = File.new(ARGV[0])
log.gets
log.gets
log.each do |l|
	line = l.split(/,/)
	i = 18
	n = 0
	while i < line.size
		domain_name[n] = line[i+1]
		cpu_ns[n] = [] if !cpu_ns[n]
		cpu_ns[n] << line[i+2].to_i
		cpu_percent[n] = [] if !cpu_percent[n]
		cpu_percent[n] << line[i+3].to_i
		net_rxby[n] = [] if !net_rxby[n]
		net_rxby[n] << line[i+8].to_i
		net_txby[n] = [] if !net_txby[n]
		net_txby[n] << line[i+9].to_i
		i += 10
		n += 1
	end
end

domain_name.each_index do |i|
	puts "#{domain_name[i]},#{cpu_ns[i].avg},#{cpu_percent[i].avg},#{net_rxby[i].avg},#{net_txby[i].avg},#{net_rxby[i].avg + net_txby[i].avg}"
end
