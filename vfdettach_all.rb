#!/usr/bin/ruby
require 'yaml'
require "#{File.dirname(__FILE__)}/lib/vf.rb"

c = YAML.load_file("#{File.dirname(__FILE__)}/config.yml")
get_vfs(c['nic1_dev']).each do |vf|
	system("virsh nodedev-dettach pci_#{vf[0]}_#{vf[1]}_#{vf[2]}_#{vf[3]}")
end
