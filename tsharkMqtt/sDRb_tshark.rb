# !/home/zhilu/.rvm/rubies/ruby-2.3.3/bin/ruby
require_relative 'tshark'
require 'drb/drb'
URI_ADDR="druby://localhost:8787"
class SDRbTshark < ZL::Tshark
    include DRb::DRbUndumped
end

class TsharkProxy

   def initialize(pkgdir,filename)
  	@pkgdir=pkgdir
	@filename=filename
   end

   def tsharkobj
	@obj=SDRbTshark.new(@pkgdir,@filename)
	return @obj
   end
end

class SDRbTshark2<ZL::Tshark
end

pkgdir="testpkgdir"
filename="test"
args=ARGV[0]
if args=="undumped"
   puts "DRB undumped SERVER #{URI_ADDR} is running..."
   FRONT_OBJECT=TsharkProxy.new(pkgdir,filename)
   p FRONT_OBJECT
   p FRONT_OBJECT.tsharkobj
   $SAFE = 1   # disable eval() and friends
else
   puts "DRB SERVER #{URI_ADDR} is running..."
   FRONT_OBJECT=SDRbTshark2.new(pkgdir,filename)
   p FRONT_OBJECT
end
DRb.start_service(URI_ADDR, FRONT_OBJECT)
DRb.thread.join
