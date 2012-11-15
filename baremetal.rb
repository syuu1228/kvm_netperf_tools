#!/usr/bin/ruby
require 'yaml'

c = YAML.load_file("#{File.dirname(__FILE__)}/config.yml")

puts "start mpstat_log"
ret = system("ssh #{c['host_ip']} screen -dm ~/kvm_netperf_tools/mpstat_log.sh baremetal")
if !ret
	puts ret
	exit 1
end

puts "start netperf"
ret = system("#{File.dirname(__FILE__)}/multi_netperf.rb #{c['max_flows']} #{c['vm_ip_fmt']} #{c['host_ip_tail']} #{c['max_flows']} #{c['duration']} ~/netperf_%s.baremetal.log")
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

