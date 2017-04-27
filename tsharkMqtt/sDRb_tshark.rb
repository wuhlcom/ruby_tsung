require_relative 'tshark'
require_relative 'public_methods'
include ZL::PubMethods
intf="eth1"
port="65534"
ip=ifip(intf)
URI_ADDR="druby://#{ip}:#{port}"
class SDRbTshark<ZL::Tshark
end
packetsdir="packets"
packetname="tsung_mqtt.pcapng"
puts "DRB undumped SERVER #{URI_ADDR} is running..."
FRONT_OBJECT=SDRbTshark.new(intf)
p FRONT_OBJECT
DRb.start_service(URI_ADDR, FRONT_OBJECT)
DRb.thread.join
