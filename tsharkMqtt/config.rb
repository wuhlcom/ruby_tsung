#执行机网卡名
@local_intf="eth1"
#分机网卡名
@remote_intf="eth1"
###tshark 服务名
@tshark_process="tshark"
###xmlpath tsung文件路径
@xmlpath="./xmls/mqtt_csv.xml"
###############ruby server ip and port
@drbsrv_ip="192.168.10.30" #druby server ip
@drbport="65534" #drb端口
@remote_clientIP="192.168.10.30" #tsung remote client
@mqttsrv_ip="192.168.10.200" #mqtt server ip
URI_ADDR="druby://#{@drbsrv_ip}:#{@drbport}" #druby address
##############capture parameters
#抓包保存目录
@packetsdir="packets"
#保存的报文件名
@packetname="tsung_mqtt.pcapng"
@filesize=1000    #抓包保存单个文件大小
@filenum=2        #保存的文件数
@cap_filter="tcp port 1883" #捕获报文时过滤条件

