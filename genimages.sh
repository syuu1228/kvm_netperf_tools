#!/bin/sh
for i in `seq 0 $1`;do qemu-img create -f qcow2 -b ubuntu.img ubuntu$i.img;done
