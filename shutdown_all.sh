#!/bin/sh
for i in `sudo virsh list |awk '{print $2}'`;do sudo virsh shutdown $i;done
