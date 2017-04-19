# !/home/zhilu/.rvm/rubies/ruby-2.3.3/bin/ruby
require_relative 'tshark'
ip="192.168.10.164"
port="65534"
URI_ADDR="druby://#{ip}:#{port}"
class SDRbTshark<ZL::Tshark
end

pkgdir="testpkgdir"
filename="test"
puts "DRB undumped SERVER #{URI_ADDR} is running..."
FRONT_OBJECT=SDRbTshark.new(pkgdir,filename)
p FRONT_OBJECT
DRb.start_service(URI_ADDR, FRONT_OBJECT)
DRb.thread.join
~                     
