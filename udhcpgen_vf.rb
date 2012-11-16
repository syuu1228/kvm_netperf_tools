#!/usr/bin/ruby
require 'yaml'
require 'erb'

c = YAML.load_file("#{File.dirname(__FILE__)}/config.yml")

no = 0
`sudo dmesg|grep "IOV: VF"`.each_line do |l|
	line = l.split
	next if line[4] != "#{c['nic1_dev']}:" 
	mac = line[11]
	ip = sprintf(c['vm_ip_fmt'], c['vm_ip_start_vf'] + no)
	puts "static_lease #{mac} #{ip}"
	no += 1
end
