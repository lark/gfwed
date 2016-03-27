#!/bin/sh

# change these variables if necessary
DNS=8.8.8.8
IPSET="REDSOCKS"

FN_SRV=/etc/dnsmasq.d/02-servers
FN_SET=/etc/dnsmasq.d/03-ipsets

# generate dnsmasq configuration. dnsmasq 2.66+ needed.

awk -v dns=${DNS} '{
	if ($0 ~ /^#/ || $0 ~ /^[ \t]*$/)
		print;
	else if ($0 ~ /^[a-zA-Z0-9._-]+$/)
		printf "server=/%s/%s\n", $0, dns; 
}' gfwed.list > ${FN_SRV}

awk -v ipset=${IPSET} '{
	if ($0 ~ /^#/ || $0 ~ /^[ \t]*$/)
		print;
	else if ($0 ~ /^[a-zA-Z0-9._-]+$/)
		printf "ipset=/%s/%s\n", $0, ipset; 
}' gfwed.list > ${FN_SET}


/etc/init.d/dnsmasq restart

# populate DIRECT as well
ipset flush DIRECT
grep -v ^# direct | xargs -L1 -I "{}" ipset add DIRECT "{}" --exist
