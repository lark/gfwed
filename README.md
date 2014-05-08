# GFWed

Some simple scripts to maintain anti-GFW configuration

## Normal usage

Put domain you want to access into `gfwed.list` and run `./update.sh` using
root

    # ./update.sh

If for some reasons, a domain will resolv to IPs you want to access directly, put
network into `direct`, and

    # ./update.sh

You can use leading `#` for comments in `gfwed.list` and `direct`. Empty lines are
ignored.

## Requirements

If you want to use this script package, you need

* A linux box as router. An openwrt box can be used too
* `redsocks`
* `dnsmasq`-2.69-2 (or above). dnsmasq-2.68 should be ok, but ipset actions are not
  logged. You may need the logs some day. If your linux distribution doesn't provide
  dnsmasq-2.69-2 or above, compile one
* `ipset` tools and kernel which supports ipset
* A socks server. `shadowsocks` is recommended

## Simple technical details

### ipset setup

There is a script in package

    ipset create REDSOCKS bitmap:ip range 0.0.0.0-255.255.255.255 netmask 16 --exist
    ipset create DIRECT hash:net --exist

### iptables setup

You need these two rules at the end of nat table chain PREROUTING

    -A PREROUTING -i eth1 -p tcp -m set --match-set DIRECT dst -j RETURN
    -A PREROUTING -i eth1 -p tcp -m set --match-set REDSOCKS dst -j REDIRECT --to-ports 12345

And nat table OUTPUT for router itself

    -A OUTPUT -p tcp -m set --match-set DIRECT dst -j RETURN
    -A OUTPUT -p tcp -m set --match-set REDSOCKS dst -j REDIRECT --to-ports 12345

### redsocks setup

Simple. I'd suggest that you use rsyslog to filter logs into a separate file, or
just use file as log directly.

    base {
            log_debug = off;
            log_info = on;
            log = "syslog:daemon";
            daemon = on;
            user = redsocks;
            group = redsocks;
            redirector = iptables;
    }
    redsocks {
            local_ip = 0.0.0.0;
            local_port = 12345;
            type = socks5;
            ip = 192.168.0.254;
            port = 1081;
    }

### dnsmasq setup

Split your dnsmasq into multiple files in `/etc/dnsmasq.d`. This gives you flexibility.

    00-settings
    01-names
    01-servers
    02-servers
    03-ipsets
    99-default

The resolved IP addresses will be add to REDSOCKS ipset rule for every name specified by
02-servers after every successful resolution. This is specified by 03-ipsets.

## Boot up issue and solution

Iptables rules depend on ipset rules. So in my debian box `/etc/rc.local`

    ...
    /root/gfwed/ipset.sh
    /etc/init.d/iptables-persistent start
    ...

## License

All these scripts are available under MIT license.


Copyright (C) 2014, Wang Jian

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
