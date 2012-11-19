#!/usr/bin/ruby
require 'yaml'
require "#{File.dirname(__FILE__)}/lib/array_extender.rb"

if ARGV.size < 1
	puts "format_mpstat.rb [interface]"
	exit 1
end

IF = ARGV[0]
c = YAML.load_file("#{File.dirname(__FILE__)}/config.yml")
ENTRIES = 9
HEADER = ",%usr,%nice,%sys,%iowait,%irq,%soft,%steal,%guest,%idle\n"

avg = File.new("mpstat_#{IF}_avg.csv", 'w')
avg.write HEADER
min = File.new("mpstat_#{IF}_min.csv", 'w')
min.write HEADER
max = File.new("mpstat_#{IF}_max.csv", 'w')
max.write HEADER
c['cpus'].each do |cpu|
	c['vms'].each do |v|
		values = Array.new(ENTRIES)
		values.each_index do |i|
			values[i] = []
		end
		log = File.new("mpstat.#{IF}#{v}-#{cpu}.log")
		log.gets
		log.gets
		log.gets
		cnt = 0
		log.each do |l|
			break if cnt == c['duration']
			line = l.split
			(0...values.size).each do |i|
				values[i] << line[i+2].to_f
			end
			cnt+=1
		end
		avg.write "#{IF}#{v}-cpu#{cpu}, "
		values.each_index do |i|
			avg.write "#{values[i].avg}, "
		end
		avg.write "\n"
		min.write "#{IF}#{v}-cpu#{cpu}, "
		values.each_index do |i|
			min.write "#{values[i].min}, "
		end
		min.write "\n"
		max.write "#{IF}#{v}-cpu#{cpu}, "
		values.each_index do |i|
			max.write "#{values[i].max}, "
		end
		max.write "\n"
	end
end
avg.close
min.close
max.close
