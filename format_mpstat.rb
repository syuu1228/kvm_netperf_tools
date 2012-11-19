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
HEADER = ",%usr,%nice,%sys,%iowait,%irq,%soft,%steal,%guest,%idle,%all\n"

avg = File.new("mpstat_#{IF}_avg.csv", 'w')
avg.write HEADER
c['cpus'].each do |cpu|
	c['vms'].each do |v|
		arr_usr = []
		arr_nice = []
		arr_sys = []
		arr_iowait = []
		arr_irq = []
		arr_soft = []
		arr_steal = []
		arr_guest = []
		arr_idle = []
		log = File.new("mpstat.#{IF}#{v}-#{cpu}.log")
		log.gets
		log.gets
		log.gets
		cnt = 0
		log.each do |l|
			break if cnt == c['duration']
			line = l.split
			arr_usr << line[3].to_f
			arr_nice << line[4].to_f
			arr_sys << line[5].to_f
			arr_iowait << line[6].to_f
			arr_irq << line[7].to_f
			arr_soft << line[8].to_f
			arr_steal << line[9].to_f
			arr_guest << line[10].to_f
			arr_idle << line[11].to_f
			cnt+=1
		end
		avg.write "#{IF}#{v}-cpu#{cpu},"
		avg.write "#{arr_usr.avg},"
		avg.write "#{arr_nice.avg},"
		avg.write "#{arr_sys.avg},"
		avg.write "#{arr_iowait.avg},"
		avg.write "#{arr_irq.avg},"
		avg.write "#{arr_soft.avg},"
		avg.write "#{arr_steal.avg},"
		avg.write "#{arr_guest.avg},"
		avg.write "#{arr_idle.avg},"
		avg.write "#{arr_usr.avg + arr_nice.avg + arr_sys.avg + arr_irq.avg + arr_soft.avg + arr_steal.avg + arr_guest.avg}\n"
	end
end
avg.close
