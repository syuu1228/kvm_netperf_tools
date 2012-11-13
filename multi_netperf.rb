#!/usr/bin/ruby
require 'csv'

module ArrayExtender
	def avg
		sum = 0.0
		self.each do |i|
			sum += i
		end
		sum / self.size		
	end

	def min
		 m = -1.0
		self.each do |i|
			m = i if m == -1 || m > i
		end
		m
	end

	def max
		 m = 0.0
		self.each do |i|
			m = i if m < i
		end
		m
	end
end
class Array
	include ArrayExtender
end

if ARGV.size < 5
	puts "multi_netperf.rb [flows] [peer_fmt] [start_with] [increment_cnt] [duration]"
	exit 1
end
flows = ARGV[0].to_i
peer_fmt = ARGV[1]
start_with = ARGV[2].to_i
increment_cnt = ARGV[3].to_i
duration = ARGV[4].to_i

v = start_with
(0 ... flows).each do |i|
	Process.fork do
		peer = sprintf(peer_fmt, v)
		exec "netperf -v2 -H #{peer} -t TCP_RR -P 0 -c -C -l #{duration} >> /tmp/netperf.log.#{i}"
	end
end
ret = Process.waitall
lat = []
tps = []

(0 ... flows).each do |i|
	log = CSV.open("/tmp/netperf.log.#{i}", mode = "r", options = {:col_sep => ' '})
	j = 0
	log.each do |row|
		if j == 5
			lat << row[4].to_f
			tps << row[5].to_f
		end
		j += 1
	end
	File.delete(log.path)
end

puts "lat"
lat.each do |v|
	puts v
end
puts "\ntps"
tps.each do |v|
	puts v
end
puts "\navg lat:#{lat.avg} tps:#{tps.avg}"
puts "min lat:#{lat.min} tps:#{tps.min}"
puts "max lat:#{lat.max} tps:#{tps.max}"

