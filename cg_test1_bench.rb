#!/usr/bin/ruby
require 'yaml'

cpu = 16
IF = 'vtap'
c = YAML.load_file("#{File.dirname(__FILE__)}/config.yml")
		v = 16
		max_flows = c['max_flows']
		flow_per_node = max_flows / v

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

		puts "start cg_test1"
		ret = system("ssh #{c['host_ip']} ~/kvm_netperf_tools/cg_test1.rb")
		if !ret
			puts ret
			exit 1
		end

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
		puts("#{File.dirname(__FILE__)}/multi_netperf.rb #{max_flows} #{c['vm_ip_fmt']} #{c["vm_ip_start_#{IF}"]} #{flow_per_node} #{c['duration']} ~/netperf_%s.#{IF}#{v}-#{cpu}.log")
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

