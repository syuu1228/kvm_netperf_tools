#!/usr/bin/ruby
require 'yaml'
require 'erb'

c = YAML.load_file("#{File.dirname(__FILE__)}/config.yml")

c['cpus'].each do |cpu|
	(0...c['max_vms']).each do |no|
		uuid = `uuidgen`
		eth0_mac = sprintf(c['eth0_mac_fmt'], no)
		eth1_mac = sprintf(c['eth1_mac_fmt'], no)
		erb = File.new("ubuntu.xml.erb")
		xml = File.new("/etc/libvirt/qemu/ubuntu#{no}-#{cpu}.xml", "w")
		xml.write(ERB.new(erb.read).result(binding))
		xml.close
		erb.close
		puts `virsh define #{xml.path}`
	end
end
