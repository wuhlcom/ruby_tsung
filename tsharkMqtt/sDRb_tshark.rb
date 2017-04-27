require_relative 'tshark'
require_relative 'public_methods'
require_relative 'config'
include ZL::PubMethods
ip=ifip(@remote_intf)
class SDRbTshark<ZL::Tshark
end
puts "DRB undumped SERVER #{URI_ADDR} is running..."
FRONT_OBJECT=SDRbTshark.new(@remote_intf)
p FRONT_OBJECT
DRb.start_service(URI_ADDR, FRONT_OBJECT)
DRb.thread.join
