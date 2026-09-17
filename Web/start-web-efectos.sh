#!/bin/sh

ifconfig eth0 192.168.50.2 netmask 255.255.255.0 up

mkdir -p /www

busybox httpd -p 80 -h /www
