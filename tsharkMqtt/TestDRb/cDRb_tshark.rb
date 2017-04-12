require 'drb/drb'
URI_ADDR="druby://localhost:8787"
DRb.start_service
tshark=DRbObject.new_with_uri(URI_ADDR)
args=ARGV[0]
if args=="undumped"
	p tshark
	p t=tshark.tsharkobj
	thr=t.tshark1
else
	#############################
	p tshark.tshark2
end
