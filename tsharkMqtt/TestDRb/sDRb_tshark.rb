# !/home/zhilu/.rvm/rubies/ruby-2.3.3/bin/ruby
#require_relative 'tshark'
require 'drb/drb'
URI_ADDR="druby://localhost:8787"
class Tshark
	def initialize(pkgdir,filename)
		@pkgdir=pkgdir
		@filename=filename	
	end
	
	def tshark1
		"tshark1"
	end
end

class SDRbTshark1 < Tshark
	 include DRb::DRbUndumped
end

class TsharkProxy

   def initialize(pkgdir,filename)
  	@pkgdir=pkgdir
	@filename=filename
   end

   def tsharkobj
	@obj=SDRbTshark1.new(@pkgdir,@filename)
	return @obj
   end
end

class SDRbTshark2 
	 def initialize(dir,filename)
		@pkgdir=dir
		@filename=filename
	 end

	 def tshark2
	   "tshark2"
	 end
	
end

args=AGRV=[0]
pkgdir="testpkgdir"
filename="test"
if args=="undumped"
	FRONT_OBJECT=TsharkProxy.new(pkgdir,filename)
	$SAFE = 1   # disable eval() and friends
else
	FRONT_OBJECT=SDRbTshark2.new(pkgdir,filename)
end
DRb.start_service(URI_ADDR, FRONT_OBJECT)
DRb.thread.join
