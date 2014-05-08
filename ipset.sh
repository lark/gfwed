#!/bin/sh

ipset create REDSOCKS bitmap:ip range 0.0.0.0-255.255.255.255 netmask 16 --exist
ipset create DIRECT hash:net --exist
