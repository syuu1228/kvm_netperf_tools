#!/usr/bin/ruby
require 'yaml'
require 'erb'

c = YAML.load_file("#{File.dirname(__FILE__)}/config.yml")

c['cpus'].each do |cpu|
	(0...c['max_vms']).each do |no|
		uuid = `uuidgen`
		nic0_mac = sprintf(c['nic0_mac_fmt'], no)
		nic1_mac = sprintf(c['nic1_mac_fmt'], no)
		nic1_dev = c['nic1_dev']
		image_path = c['image_path']
		erb = File.new("ubuntu.xml.erb")
		xml = File.new("/etc/libvirt/qemu/ubuntu#{no}-#{cpu}.xml", "w")
		xml.write(ERB.new(erb.read).result(binding))
		xml.close
		erb.close
		puts `virsh define #{xml.path}`
	end
end
