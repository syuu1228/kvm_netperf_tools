#!/usr/bin/ruby
VMS = [1, 2, 4, 8, 16, 32, 64, 128]
FLOWS = [128, 64, 32, 16, 8, 4, 2, 1]
CPUS = [1, 2, 4, 8, 16]
DURATION = 180

CPUS.each do |cpu|
	(0...VMS.size).each do |i|
		v = VMS[i]
		f = FLOWS[i]
		next if File.exists?("netperf.#{v}-#{cpu}.log")

		(0...v).each do |j|
			puts "start vm#{j}-#{cpu}"
			ret = system("ssh 10.0.0.2 sudo virsh start ubuntu#{j}-#{cpu}")
			if !ret
				puts ret
				exit 1
			end
		end
		puts "sleep 360"
		sleep 360
		puts "start kvm_stat_log"
		ret = system("ssh 10.0.0.2 screen -dm ~/kvm_stat_log.sh #{v}-#{cpu}")
		if !ret
			puts ret
			exit 1
		end

		puts "start mpstat_log"
		ret = system("ssh 10.0.0.2 screen -dm ~/mpstat_log.sh #{v}-#{cpu}")
		if !ret
			puts ret
			exit 1
		end

		puts "start netperf"
		ret = system("~/multi_netperf.rb #{v} 10.0.0.%d 3 #{f} #{DURATION} 2>&1|tee netperf.#{v}-#{cpu}.log")
		if !ret
			puts ret
			exit 1
		end

		puts "kill kvm_stat"
		ret = system("ssh 10.0.0.2 sudo killall python2.7")
		if !ret
			puts ret
			exit 1
		end

		puts "kill mpstat"
		ret = system("ssh 10.0.0.2 sudo killall mpstat")
		if !ret
			puts ret
			exit 1
		end

		puts "start shutdown"
		(0...v).each do |j|
			ret = system("ssh 10.0.0.2 sudo virsh shutdown ubuntu#{j}-#{cpu}")
			if !ret
				puts ret
				exit 1
			end
		end

		while true do
			puts "list"
			list = `ssh 10.0.0.2 sudo virsh list`
			break if list.count("\n") == 3
		end
	end
end
