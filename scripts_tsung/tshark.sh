#!/usr/bin/ruby
#tshark capture
capture(){
 filter=$1
 tshark -i eth0 -f "tcp port 1883" -Tfields -e ip.src -e ip.dst -e mqtt.msg -e mqtt.topic -E header=y -w mqtt.pcapng -a filesize:1000 -a files:1
}

