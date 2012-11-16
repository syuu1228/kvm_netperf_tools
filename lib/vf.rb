#!/usr/bin/ruby

def get_vfs(pf)
	vfs = []
	n = Dir::glob("/sys/class/net/#{pf}/device/virtfn*").size
	(0...n).each do |i|
		f = File.new("/sys/class/net/#{pf}/device/virtfn#{i}")
		vfs << File.basename(File.readlink(f)).split(/:|\./)
	end
	vfs
end
