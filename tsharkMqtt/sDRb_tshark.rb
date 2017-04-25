require_relative 'tshark'
ip="192.168.10.30"
#ip=ifip
port="65534"
URI_ADDR="druby://#{ip}:#{port}"
class SDRbTshark<ZL::Tshark
end
packetsdir="packets"
packetname="tsung_mqtt.pcapng"
intf="eth1"
puts "DRB undumped SERVER #{URI_ADDR} is running..."
FRONT_OBJECT=SDRbTshark.new(intf)
p FRONT_OBJECT
DRb.start_service(URI_ADDR, FRONT_OBJECT)
DRb.thread.join
