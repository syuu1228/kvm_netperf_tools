#!/usr/bin/ruby
require 'yaml'
require 'erb'
require "#{File.dirname(__FILE__)}/lib/vf.rb"

c = YAML.load_file("#{File.dirname(__FILE__)}/config.yml")
vfs = get_vfs(c['nic1_dev'])

['vtap', 'vf'].each do |interface|
	c['cpus'].each do |cpu|
		max = c['max_vms']
		max = vfs.size if interface == 'vf' && max > vfs.size
		(0...max).each do |no|
			uuid = `uuidgen`
			nic0_mac = sprintf(c['nic0_mac_fmt'], no)
			if interface  == 'vtap'
				nic1_mac = sprintf(c['nic1_mac_fmt'], no)
				nic1_dev = c['nic1_dev']
			else
				vf_bus = vfs[no][1]
				vf_slot = vfs[no][2]
				vf_function = vfs[no][3]
			end
			image_path = c['image_path']
			erb = File.new("ubuntu_#{interface}.xml.erb")
			xml = File.new("/etc/libvirt/qemu/ubuntu_#{interface}#{no}-#{cpu}.xml", "w")
			xml.write(ERB.new(erb.read).result(binding))
			xml.close
			erb.close
			puts `virsh define #{xml.path}`
		end
	end
end
