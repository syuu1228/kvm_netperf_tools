#!/bin/sh
sudo vmstat -n 10 > ~/vmstat.$1.log
