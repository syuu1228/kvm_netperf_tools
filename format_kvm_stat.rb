#!/usr/bin/ruby
require 'yaml'
require "#{File.dirname(__FILE__)}/lib/array_extender.rb"

c = YAML.load_file("#{File.dirname(__FILE__)}/config.yml")
ENTRIES = 74
HEADER = ",kvm_ack_irq,kvm_age_page,kvm_apic,kvm_apic_accept_irq,kvm_apic_ipi,kvm_async_pf_completed,kvm_async_pf_doublefault,kvm_async_pf_not_present,kvm_async_pf_ready,kvm_cpuid,kvm_cr,kvm_emulate_insn,kvm_entry,kvm_exit,kvm_exit(APIC_ACCESS),kvm_exit(CPUID),kvm_exit(CR_ACCESS),kvm_exit(DR_ACCESS),kvm_exit(EPT_MISCONFIG),kvm_exit(EPT_VIOLATION),kvm_exit(EXCEPTION_NMI),kvm_exit(EXTERNAL_INTERRUPT),kvm_exit(HLT),kvm_exit(INVALID_STATE),kvm_exit(INVLPG),kvm_exit(IO_INSTRUCTION),kvm_exit(MCE_DURING_VMENTRY),kvm_exit(MONITOR_INSTRUCTION),kvm_exit(MSR_READ),kvm_exit(MSR_WRITE),kvm_exit(MWAIT_INSTRUCTION),kvm_exit(NMI_WINDOW),kvm_exit(PAUSE_INSTRUCTION),kvm_exit(PENDING_INTERRUPT),kvm_exit(RDPMC),kvm_exit(RDTSC),kvm_exit(TASK_SWITCH),kvm_exit(TPR_BELOW_THRESHOLD),kvm_exit(TRIPLE_FAULT),kvm_exit(VMCALL),kvm_exit(VMCLEAR),kvm_exit(VMLAUNCH),kvm_exit(VMOFF),kvm_exit(VMON),kvm_exit(VMPTRLD),kvm_exit(VMPTRST),kvm_exit(VMREAD),kvm_exit(VMRESUME),kvm_exit(VMWRITE),kvm_exit(WBINVD),kvm_exit(XSETBV),kvm_fpu,kvm_hv_hypercall,kvm_hypercall,kvm_inj_exception,kvm_inj_virq,kvm_invlpga,kvm_ioapic_set_irq,kvm_mmio,kvm_msi_set_irq,kvm_msr,kvm_nested_intercepts,kvm_nested_intr_vmexit,kvm_nested_vmexit,kvm_nested_vmexit_inject,kvm_nested_vmrun,kvm_page_fault,kvm_pic_set_irq,kvm_pio,kvm_set_irq,kvm_skinit,kvm_try_async_get_page,kvm_userspace_exit,vcpu_match_mmio\n"

avg = File.new("kvm_stat_avg.csv", 'w')
avg.write HEADER
min = File.new("kvm_stat_min.csv", 'w')
min.write HEADER
max = File.new("kvm_stat_max.csv", 'w')
max.write HEADER
c['cpus'].each do |cpu|
	c['vms'].each do |v|
		values = Array.new(ENTRIES)
		values.each_index do |i|
			values[i] = []
		end
		log = File.new("kvm_stat.#{v}-#{cpu}.log")
		cnt = 0
		log.each do |l|
			break if cnt == c['duration']
			line = l.split
			next if line[0] == 'kvm_ack_i'
			line.each_index do |i|
				values[i] << line[i].to_i
			end
			cnt+=1
		end
		avg.write "vm#{v}-cpu#{cpu}, "
		values.each_index do |i|
			avg.write "#{values[i].avg}, "
		end
		avg.write "\n"
		min.write "vm#{v}-cpu#{cpu}, "
		values.each_index do |i|
			min.write "#{values[i].min}, "
		end
		min.write "\n"
		max.write "vm#{v}-cpu#{cpu}, "
		values.each_index do |i|
			max.write "#{values[i].max}, "
		end
		max.write "\n"
	end
end
avg.close
min.close
max.close
