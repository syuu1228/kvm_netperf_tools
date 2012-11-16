#!/usr/bin/ruby
require 'yaml'
require 'erb'

c = YAML.load_file("#{File.dirname(__FILE__)}/config.yml")

(0...c['max_vms_vtap']).each do |no|
	mac = sprintf(c['nic1_mac_fmt'], no)
	ip = sprintf(c['vm_ip_fmt'], c['vm_ip_start_vtap'] + no)
	puts "static_lease #{mac} #{ip}"
end
