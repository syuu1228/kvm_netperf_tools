#!/usr/bin/ruby

def get_vfs(pf)
	vfs = []
	Dir::glob("/sys/class/net/#{pf}/device/virtfn*").each do |d|
		vfs << File.basename(File.readlink(d)).split(/:|\./)
	end
	vfs
end
