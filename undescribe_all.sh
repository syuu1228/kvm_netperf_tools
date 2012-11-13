#!/bin/sh
for i in `sudo virsh list --all|awk '{print $2}'`;do sudo virsh undescribe $i;done
