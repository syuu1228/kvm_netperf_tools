#!/usr/bin/ruby

module ArrayExtender
	def avg
		sum = 0.0
		self.each do |i|
			sum += i
		end
		sum / self.size		
	end

	def min
		m = -1
		self.each do |i|
			m = i if m == -1 || m > i
		end
		m
	end

	def max
		m = 0
		self.each do |i|
			m = i if m < i
		end
		m
	end
end
class Array
	include ArrayExtender
end

VMS = [1, 2, 4, 8, 16, 32, 64, 128]
CPUS = [1, 2, 4, 8, 16]
ENTRIES = 9
DURATION = 180

HEADER = ",%usr,%nice,%sys,%iowait,%irq,%soft,%steal,%guest,%idle\n"

avg = File.new("mpstat_avg.csv", 'w')
avg.write HEADER
min = File.new("mpstat_min.csv", 'w')
min.write HEADER
max = File.new("mpstat_max.csv", 'w')
max.write HEADER
CPUS.each do |cpu|
	VMS.each do |v|
		values = Array.new(ENTRIES)
		values.each_index do |i|
			values[i] = []
		end
		log = File.new("mpstat.#{v}-#{cpu}.log")
		log.gets
		log.gets
		log.gets
		cnt = 0
		log.each do |l|
			break if cnt == DURATION
			line = l.split
			(2...line.size).each do |i|
				values[i-2] << line[i].to_i
			end
			cnt+=1
		end
		avg.write "vm#{v}-cpu#{cpu}, "
		values.each_index do |i|
			avg.write "#{values[i].avg}, "
		end
		avg.write "\n"
		min.write "vm#{v}-cpu#{cpu}, "
		values.each_index do |i|
			min.write "#{values[i].min}, "
		end
		min.write "\n"
		max.write "vm#{v}-cpu#{cpu}, "
		values.each_index do |i|
			max.write "#{values[i].max}, "
		end
		max.write "\n"
	end
end
avg.close
min.close
max.close
