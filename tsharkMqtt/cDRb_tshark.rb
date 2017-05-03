require_relative 'tshark'
require_relative 'tsung.rb'
require_relative 'config'
require 'benchmark'
#初始化本地Tshark对象
l_tshark=ZL::Tshark.new(@local_intf) 
#本机IP地址	
localIP=l_tshark.ifip(@local_intf)
###parse packets filters
ex_filter="mqtt.msgtype==3 && (ip.src==#{@mqttsrv_ip}||ip.src==#{localIP})"
ex_filter2="mqtt.msgtype==3 && (ip.src==#{@mqttsrv_ip}||ip.src==#{@remote_clientIP})"
pub_filter="mqtt.msgtype==3 && ip.src==#{localIP}"
pub_filter2="mqtt.msgtype==3 && ip.src==#{@remote_clientIP}"
rev_filter="mqtt.msgtype==3 && ip.src==#{@mqttsrv_ip}"
###DRb 启动
DRb.start_service
r_tshark=DRbObject.new_with_uri(URI_ADDR)

#0 生成tsung配置文件
#1 开始抓包
puts "[#{Time.now}]step 1: capture beginning....."
#本地客户端抓包
l_tshark.capture(@cap_filter,@filesize,@filenum)	
#远程客户端抓包
r_tshark.capture(@cap_filter,@filesize,@filenum)
sleep 60
#2 开始tsung
puts "[#{Time.now}]step 2: tsung starting....."
tsung=ZL::Tsung.new(@xmlpath)
flag=tsung.tsung_start

#3 结束tsung，停止抓包
puts "[#{Time.now}]step 3: tsung finished  and tshark stoped....."
if flag==true
  sleep 30
  r_tshark.linuxpkill(@tshark_process)
  l_tshark.linuxpkill(@tshark_process)
end

#4 解析报文并写入数据库
puts "[#{Time.now}]step 4: parser packets..."
l_tshark.write_records(ex_filter,pub_filter,rev_filter)
r_tshark.write_records(ex_filter2,pub_filter2,rev_filter)

#5 写入最终结果 
puts "[#{Time.now}]step 5: result..."
l_tshark.write_result


