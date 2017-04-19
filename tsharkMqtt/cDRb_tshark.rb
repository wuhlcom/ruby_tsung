require_relative 'tshark'
require_relative 'tsung.rb'
require 'benchmark'
##
tshark_process="tshark"
###xmlpath
xmlpath="./xmls/mqtt_csv.xml"
####ruby server ip and port
ip="192.168.10.164"
port="65534"
URI_ADDR="druby://#{ip}:#{port}"
###capture parameters
filesize=2000
filenum=2
filename="mqtt" 
cap_filter="tcp port 1883"
###parse packets filters
ex_filter="mqtt.msgtype==3 && (ip.src==192.168.10.166||ip.src==192.168.10.8)"
pub_filter="mqtt.msgtype==3 && ip.src==192.168.10.166"
rev_filter="mqtt.msgtype==3 && ip.src==192.168.10.8"
###DRb
DRb.start_service
tshark=DRbObject.new_with_uri(URI_ADDR)

#0 生成tsung配置文件

#1 开始抓包
puts "[#{Time.now}]step 1: capture beginning....."
l_tshark=ZL::Tshark.new() 	
#本地客户端抓包
l_tshark.capture(cap_filter,10,1)	
#远程客户端抓包
tshark.capture(cap_filter,filesize,filenum)

#2 开始tsung
puts "[#{Time.now}]step 2: tsung starting....."
tsung=ZL::Tsung.new(xmlpath)
flag=tsung.tsung_start

#3 结束tsung，停止抓包
puts "[#{Time.now}]step 3: tsung end and tshark stop....."
if flag==true
  tshark.linuxpkill(tshark_process)
  l_tshark.linuxpkill(tshark_process)
end

#4 解析报文并写入数据库
puts "[#{Time.now}]step 4: parser packets..."
l_tshark.write_records(ex_filter,pub_filter,rev_filter)
#tshark.write_records(ex_filter,pub_filter,rev_filter)

#5 写入最终结果 
puts "[#{Time.now}]step 5: result..."
#l_tshark.write_result
#   Benchmark.bm(7) do |x|
#  	 x.report("pubs"){ 		
	
# 	 }
#end


