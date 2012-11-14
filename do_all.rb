#!/usr/bin/ruby
require 'yaml'

c = YAML.load_file("#{File.dirname(__FILE__)}/config.yml")

c['cpus'].each do |cpu|
	(0...c['vms'].size).each do |i|
		v = c['vms'][i]
		f = c['flows'][i]
		if !v
			puts "v:#{v}"
			exit 1
		end
		if !f
			puts "f:#{f}"
			exit 1
		end
		next if File.exists?("~/netperf.#{v}-#{cpu}.log")

		(0...v).each do |j|
			puts "start vm#{j}-#{cpu}"
			ret = system("ssh #{c['host_ip']} sudo virsh start ubuntu#{j}-#{cpu}")
			if !ret
				puts ret
				exit 1
			end
		end
		(0...v).each do |j|
			puts "waiting to startup vm#{j}-#{cpu}"
			while true do
				break if system("ping -c1 #{sprintf(c['vm_ip_fmt'], c['vm_ip_start'] + j)}")
			end
		end
		puts "sleep #{c['sleep_for_vmstart']}"
		sleep c['sleep_for_vmstart']
		puts "start kvm_stat_log"
		ret = system("ssh #{c['host_ip']} screen -dm ~/kvm_netperf_tools/kvm_stat_log.sh #{v}-#{cpu}")
		if !ret
			puts ret
			exit 1
		end

		puts "start mpstat_log"
		ret = system("ssh #{c['host_ip']} screen -dm ~/kvm_netperf_tools/mpstat_log.sh #{v}-#{cpu}")
		if !ret
			puts ret
			exit 1
		end

		puts "start netperf"
		puts "#{File.dirname(__FILE__)}/multi_netperf.rb #{v} #{c['vm_ip_fmt']} #{c['vm_ip_start']} #{f} #{c['duration']} ~/netperf_%s.#{v}-#{cpu}.log"
		ret = system("#{File.dirname(__FILE__)}/multi_netperf.rb #{v} #{c['vm_ip_fmt']} #{c['vm_ip_start']} #{f} #{c['duration']} ~/netperf_%s.#{v}-#{cpu}.log")
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

		puts "start shutdown"
		(0...v).each do |j|
			ret = system("ssh #{c['host_ip']} sudo virsh shutdown ubuntu#{j}-#{cpu}")
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
