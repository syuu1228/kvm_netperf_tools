#!/usr/bin/ruby

grp_a = []
grp_b = []

(0..15).each do |i|
	tasks = File.new("/sys/fs/cgroup/cpu/libvirt/qemu/ubuntu_vtap#{i}-1/tasks", 'r')
	while pid = tasks.gets
		if i < 8
			grp_a << pid.to_i
		else
			grp_b << pid.to_i
		end
	end
	Dir.glob("/sys/fs/cgroup/cpu/libvirt/qemu/ubuntu_vtap#{i}-1/vcpu*/tasks").each do |t|
		tasks = File.new(t, 'r')
		while pid = tasks.gets
			if i < 8
				grp_a << pid.to_i
			else
				grp_b << pid.to_i
			end
		end
	end
end

Dir.mkdir("/sys/fs/cgroup/cpu/grp_a")
Dir.mkdir("/sys/fs/cgroup/cpu/grp_b")
grp_a.each do |pid|
	tasks = File.new("/sys/fs/cgroup/cpu/grp_a/tasks", 'w')
	tasks.write "#{pid}\n"
	tasks.close
end
grp_b.each do |pid|
	tasks = File.new("/sys/fs/cgroup/cpu/grp_b/tasks", 'w')
	tasks.write "#{pid}\n"
	tasks.close
end
shares = File.new("/sys/fs/cgroup/cpu/grp_a/cpu.shares", 'w')
shares.write "1024"
shares.close

shares = File.new("/sys/fs/cgroup/cpu/grp_b/cpu.shares", 'w')
shares.write "512"
shares.close
