#!/usr/bin/ruby
require 'yaml'

if ARGV.size < 1
	puts "do_all.rb [interface]"
	exit 1
end

IF = ARGV[0]
c = YAML.load_file("#{File.dirname(__FILE__)}/config.yml")

c['cpus'].each do |cpu|
	(0...c['vms'].size).each do |i|
		v = c['vms'][i]
		max_flows = c['max_flows']
		flow_per_node = max_flows / v
		if v > c["max_vms_#{IF}"]
			v = c["max_vms_#{IF}"]
			max_flows = v * flow_per_node
		end
		puts "[#{IF}#{v}-#{cpu}] flow_per_node:#{flow_per_node}"
		if !v
			puts "v is nil"
			exit 1
		end
		next if File.exists?(File.expand_path("~/netperf_lat.#{IF}#{v}-#{cpu}.log"))
		puts "clear swap"
		ret = system("ssh #{c['host_ip']} sudo swapoff -a")
		if !ret
			puts ret
			exit 1
		end
		ret = system("ssh #{c['host_ip']} sudo swapon -a")
		if !ret
			puts ret
			exit 1
		end

		(0...v).each do |j|
			puts "start #{IF}#{j}-#{cpu}"
			ret = system("ssh #{c['host_ip']} sudo virsh start ubuntu_#{IF}#{j}-#{cpu}")
			if !ret
				puts ret
				exit 1
			end
		end
		(0...v).each do |j|
			puts "waiting to startup #{IF}#{j}-#{cpu}"
			while true do
				break if system("ping -c1 #{sprintf(c['vm_ip_fmt'], c["vm_ip_start_#{IF}"] + j)}")
			end
		end
		puts "sleep #{c['sleep_for_vmstart']}"
		sleep c['sleep_for_vmstart']
		puts "start kvm_stat_log"
		ret = system("ssh #{c['host_ip']} screen -dm ~/kvm_netperf_tools/kvm_stat_log.sh #{IF}#{v}-#{cpu}")
		if !ret
			puts ret
			exit 1
		end

		puts "start mpstat_log"
		ret = system("ssh #{c['host_ip']} screen -dm ~/kvm_netperf_tools/mpstat_log.sh #{IF}#{v}-#{cpu}")
		if !ret
			puts ret
			exit 1
		end

		puts "start vmstat_log"
		ret = system("ssh #{c['host_ip']} screen -dm ~/kvm_netperf_tools/vmstat_log.sh #{IF}#{v}-#{cpu}")
		if !ret
			puts ret
			exit 1
		end

		puts "start virt-top_log"
		ret = system("ssh #{c['host_ip']} screen -dm ~/kvm_netperf_tools/virt-top_log.sh #{IF}#{v}-#{cpu}")
		if !ret
			puts ret
			exit 1
		end

		puts "start netperf"
		ret = system("#{File.dirname(__FILE__)}/multi_netperf.rb #{max_flows} #{c['vm_ip_fmt']} #{c["vm_ip_start_#{IF}"]} #{flow_per_node} #{c['duration']} ~/netperf_%s.#{IF}#{v}-#{cpu}.log")
		if !ret
			puts ret
			exit 1
		end

		puts "kill kvm_stat"
		ret = system("ssh #{c['host_ip']} sudo killall python2.7")
		if !ret
			puts ret
			exit 1
		end

		puts "kill mpstat"
		ret = system("ssh #{c['host_ip']} sudo killall mpstat")
		if !ret
			puts ret
			exit 1
		end

		puts "kill vmstat"
		ret = system("ssh #{c['host_ip']} sudo killall vmstat")
		if !ret
			puts ret
			exit 1
		end

		puts "kill virt-top"
		ret = system("ssh #{c['host_ip']} sudo killall virt-top")
		if !ret
			puts ret
			exit 1
		end

		puts "start shutdown"
		(0...v).each do |j|
			ret = system("ssh #{c['host_ip']} sudo virsh shutdown ubuntu_#{IF}#{j}-#{cpu}")
			if !ret
				puts ret
				exit 1
			end
		end

		while true do
			puts "list"
			list = `ssh #{c['host_ip']} sudo virsh list`
			break if list.count("\n") == 3
		end
	end
end
