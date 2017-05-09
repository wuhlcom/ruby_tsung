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

#1 开始抓包################################
puts "[#{Time.now}]step 1: capture beginning....."
#本地客户端抓包
l_tshark.capture(@cap_filter,@filesize,@filenum)	
#远程客户端抓包
r_tshark.capture(@cap_filter,@filesize,@filenum)

#2 创建redis 账户
puts "[#{Time.now}]step 2:create redis accounts....."
sub_id_pre1="tsungsubz"
pub_id_pre1="tsungpubz"

sub_id_pre2="tsungsubl"
pub_id_pre2="tsungpubl"

l_tshark.hmset_accounts(@acc_num,@redis_ip,sub_id_pre1,"mqttclient","mqttclient")
l_tshark.hmset_accounts(@acc_num,@redis_ip,pub_id_pre1,"mqttclient","mqttclient")
r_tshark.hmset_accounts(@acc_num,@redis_ip,sub_id_pre2,"mqttclient","mqttclient")
r_tshark.hmset_accounts(@acc_num,@redis_ip,pub_id_pre2,"mqttclient","mqttclient")

#3 创建CSV文件
puts "[#{Time.now}]step 3:create tsung csv....."
topic1="tsungTopicz"
msg1="tsungMsgz"
topic2="tsungTopicl"
msg2="tsungMsgl"
l_tshark.tsung_csv(@sub_csv,@acc_num,sub_id_pre1,topic1)
l_tshark.tsung_csv(@pub_csv,@acc_num,pub_id_pre1,topic1,msg1)

r_tshark.tsung_csv(@sub_csv,@acc_num,sub_id_pre2,topic2)
r_tshark.tsung_csv(@pub_csv,@acc_num,pub_id_pre2,topic2,msg2)

#4 修改tsung xml配置
puts "[#{Time.now}]step 4:config tsung xml....."
p local_host=l_tshark.hostname
p remote_host=r_tshark.hostname
l_tshark.change_client(@xmlpath,local_host,localIP)
remoteIP=r_tshark.ifip(@remote_intf)
r_tshark.change_client(@xmlpath,remote_host,remoteIP)

#5 开始tsung##############################
puts "[#{Time.now}]step 5: tsung starting....."
#tsung=ZL::Tsung.new(@xmlpath)
#flag=tsung.tsung_start
flag1=r_tshark.tsung_start(@xmlpath)
flag2=l_tshark.tsung_start(@xmlpath)

#6 结束tsung，停止抓包########################
puts "[#{Time.now}]step 6: tsung finished  and tshark stoped....."
if flag1==true
  r_tshark.linuxpkill(@tshark_process)
end

if flag2==true
  l_tshark.linuxpkill(@tshark_process)
end

#7 解析报文并写入数据库
puts "[#{Time.now}]step 7: parse packets..."
#先写入所有pub
l_tshark.get_pkgfiles
l_tshark.write_pubs(ex_filter,pub_filter)
r_tshark.get_pkgfiles
r_tshark.write_pubs(ex_filter2,pub_filter2)
#再更新所有revpub
l_tshark.write_revpubs(rev_filter)
r_tshark.write_revpubs(rev_filter)
#8 写入最终结果 
puts "[#{Time.now}]step 8: result..."
l_tshark.write_result


