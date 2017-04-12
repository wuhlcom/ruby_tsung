require 'drb/drb'
URI_ADDR="druby://localhost:8787"
URI_ADDR="druby://192.168.10.164:8787"
filter="tcp"
filesize=2000
filenum=2
args=ARGV[0]

DRb.start_service
tshark=DRbObject.new_with_uri(URI_ADDR)
p tshark
if args=="undumped" 
	remoteObj=tshark.tsharkobj
	p remoteObj
	p remoteObj.get_pkgfiles
	remoteObj.capture(filter,filesize,filenum)
	p remoteObj.psef
	#remoteObj.stop_cap
	p remoteObj.psef
	#remoteObj.linuxpkill
	#p remoteObj.psef
else
  p tshark.psef
   tshark.capture(filter,filesize,filenum)
  p tshark.psef
   tshark.linuxpkill
  p tshark.psef
end
print `ps -ef|grep tshark|grep -vE 'grep|vim|ruby'`


