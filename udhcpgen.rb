#!/usr/bin/ruby
require 'yaml'
require 'erb'

c = YAML.load_file("#{File.dirname(__FILE__)}/config.yml")

c['cpus'].each do |cpu|
	(0...c['max_vms']).each do |no|
		mac = sprintf(c['nic1_mac_fmt'], no)
		ip = sprintf(c['vm_ip_fmt'], c['vm_ip_start'] + no)
		puts "static_lease #{mac} #{ip}"
	end
end
