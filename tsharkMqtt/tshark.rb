# !/home/zhilu/.rvm/rubies/ruby-2.3.3/bin/ruby
require 'pp'
require 'time'
require 'json'
require_relative 'float'
require_relative 'recorder'
require_relative 'public_methods'
require_relative 'tsung'
require_relative 'redis'
require_relative 'tsung_xml'
require_relative 'tsung_csv'
require 'drb/drb'
module ZL

  class Tshark
    include Recorder 
    include PubMethods 
    include TsungOpt
    include Redis
    include ParseXML
    include TsungCSV 
    include DRb::DRbUndumped
 
    #default display filter fields
    FTIME="frame.time"
    TIME_EPOCH='frame.time_epoch'
    IPSRC="ip.src"
    IPDST="ip.dst"
    MQTOPIC="mqtt.topic"
    MQMSG="mqtt.msg"
    MSGTYPE="mqtt.msgtype"
    FIELDS="-e #{FTIME} -e #{TIME_EPOCH} -e #{MQTOPIC} -e #{MQMSG}" 
    EMPTYFLAG=false #调试使用当为true会清空数据库表
    #DEFAULT_PKGSDIR=File.expand_path("packets",File.dirname(__FILE__))
    DEFAULT_PKGSDIR="packets"
    
    attr_accessor :pkgsdir,:pkgs_expdir,:pkgs
    def initialize(intf="eth0",pkgsdir=DEFAULT_PKGSDIR,filename="tsung_mqtt.pcapng")
       @intf=intf
       @pkgsdir="./#{pkgsdir}"
       @filename=filename
       #@pkgspath="#{@pkgsdir}/#{@filename}"
       @pkgs=nil
       @capthr=nil
    end
    
    #更改目录，子目录，子文件，子目录权限 
    def chownR_pkg
        chown_R(DEFAULT_PKGSDIR)
    end
  
    #创建抓包目录 
    def create_dirs
       time=Time.now.strftime("%Y%m%d-%H%M%S")
       @pkgsdir="#{@pkgsdir}/#{time}"
       @pkgspath="#{@pkgsdir}/#{@filename}"
       mk_dir(@pkgsdir)
       @pkgs_expdir="#{@pkgsdir}/expkgs"
       mk_dir(@pkgs_expdir)
       chmod_R("777",DEFAULT_PKGSDIR) 
    end

    #获取所有包文件名
    def get_pkgfiles()
        chownR_pkg
	pkg_basename=File.basename(@filename,".*")
  	@src_pkgs=[]
  	@src_pkgs=Dir.glob("#{@pkgsdir}/*").select{|file|file =~ /#{pkg_basename}/}	
    end

    def set_fields(efields="")
    	if !efields.empty?
    		fields=FIELDS+" "+efields 
        else
        	FIELDS
    	end
    end

     #tshark -i eth0 -f "tcp port 1883" -Tfields -e ip.src -e ip.dst -e mqtt.msg -e mqtt.topic -E header=y -w mqtt.pcapng -a duration:200 
     #tshark -i eth0 -f "tcp port 1883" -w mqtt.pcapng -a filesize:1000000 -a files:10
     def capture(filter,filesize=200000,fileNumber=10)
	create_dirs
        begin
		@capthr=Thread.new do
	             rs=`sudo tshark -i #{@intf} -f "#{filter}" -w #{@pkgspath} -a filesize:#{filesize} -a files:#{fileNumber}`
	        end
        	sleep 10 
	        #@capthr.abort_on_exception=true
	rescue =>ex
                puts ex.message.to_s
	end
	return @capthr
     end 
   
     def stop_cap
         if !@capthr.nil? && @capthr.alive?
	        @capthr.exit 
	        sleep 2
         end
	 return @capthr
    end

    #过滤出要解析的所有报文并保存
    #tshark -r mqtt.pcapng -Y "mqtt.msgtype==3 && (ip.src==192.168.10.166||ip.src==192.168.10.8)" -w tsung.pcapng 
    #为了提高解析效率这里对报文进行一次显示过滤并保存
    #可以提高约一倍的解析效率
    #parameter: 
    #--pkgpath
    #--filter,过滤条件
    #--flag，是否进行过滤
    def export_pkgs(pkgpath,filter,flag=true)  
        chownR_pkg 
   	@pkgs=pkgpath     
        if flag
           expath="#{@pkgs_expdir}/#{File.basename(pkgpath)}"            
           cmd="tshark -r \"#{pkgpath}\" -Y \"#{filter}\" -w \"#{expath}\""
       	   rs=system(cmd) 
       	   if rs        
    	      @pkgs=expath 
    	   else
    	      warn("ERROR:export packet failed,the pkgpath is '#{pkgpath}'")  
    	   end 	 
        end
        return @pkgs
   end
   
   #json格式
   #tshark -r packet.pcapng -c 50 -Tjson -e frame.time -e ip.src -e ip.dst -e mqtt.topic -e mqtt.msg -E header=y -Y mqtt.msg=="hehe"
   def tshark_rtjson(filter,efields="")
        chownR_pkg 
	res=[]
        fields=set_fields efields
	rs=`tshark -r "#{@pkgs}" -Tjson #{fields} -Y "#{filter}"`
	unless rs.nil?	
	 	res=JSON.parse(rs)	
        end
	return res 
   end

   #eK参数解析结果也为json格式
   #tshark -r packet.pcapng -c 50 -TeK -e frame.time -e ip.src -e ip.dst -e mqtt.topic -e mqtt.msg -E header=y -Y mqtt.msg=="hehe"
   def tshark_rtek(filter,efields="")
        chownR_pkg 
 	res=[]
        fields=set_fields efields
	rs=`tshark -r "#{@pkgspath}" -TeK #{fields} -Y "#{filter}"`
	unless rs.nil?	
	 	res=JSON.parse(rs)	
	 end
	return res 
  end

   #tshark -r packet.pcapng -c 50 -Tfields -e frame.time -e ip.src -e ip.dst -e mqtt.topic -e mqtt.msg -E header=y -Y mqtt.msg=="hehe"
   def tshark_rtfields(filter,efields="")	 
	   chownR_pkg	
	   fields=set_fields efields
	   #分割fields作为key
	   keys=fields.split(/\s*-e\s*/)
  	   keys.delete("")	
	   rarr=[]	
	   rs=`tshark -r #{@pkgs} -Tfields #{fields} -Y "#{filter}"` #注意filer外要加双引号
	   if !rs.nil?		
			value_arr=rs.split("\n") #分割不同报文
			value_arr.each do |item|
				rhash={}
				values=item.split(/\t/) #分割一个报文中不同字段

				values.each_with_index {|value,index|
                                        if keys[index]==TIME_EPOCH
                                           value=BigDecimal.new(value)
                                        end 
                                        rhash[keys[index]]=value
                                }   

				rarr<<rhash
			end
	  end
	  return rarr
  end

  def json_delay(filter,efields="")
		times={}
		value=0
		rs=tshark_rtjson(@pkgspath,filter,efields)
		
        	if !rs.nil? && !rs.empty?
	        	if rs.size==2		
	 		 
			 tstr1=rs[0]["_source"]["layers"]["frame.time"][0]		
			 t1=Time.parse(tstr1)
			 
			 tstr2=rs[1]["_source"]["layers"]["frame.time"][0]
			 t2=Time.parse(tstr2)
			 
			 value=(t2-t1).roundn(-3)				
			 times={pub_time: t1,delay_time: value}
			else       
	                   value=rs[0]["_source"]["layers"]
	                   msg="Error: #{filter} Only one message captured,value is #{value}"  
		        end
		else
			msg="#{filter} No packet captured"
		end		
  end

   #针对一发一收
   def fields_delay(filter,efields="")
	value=0
	times={}
	rs=tshark_rtfields(filter,efields)
	if !rs.nil? && !rs.empty?
		if rs.size==2
			tstr1=rs[0][FTIME]
			t1=Time.parse(tstr1)
			tstr2=rs[1][FTIME]
			t2=Time.parse(tstr2)	

			value=(t2-t1).roundn(-3)				
         		times={pub_time: t1,delay_time: value}
		else		
	          value=rs[0]	   
	          msg="Error: #{filter} Only one message captured,value is #{value}"  
		end
	else
		msg="#{filter} No packet captured"
	end
   end

    # tshark -r mqtt.pcapng -Tfields -e frame.time -e ip.src -e ip.dst -e mqtt.msg -e mqtt.topic -Y "mqtt.msgtype==3 && ip.src==192.168.10.166"
    #针对pub，解析报文并保存到数据库
    #pkgsize，一次写入数据库条目数，修改此值能略微提高速率
    def pub_pkg(filter,pkgsize,efields="")
	self.empty_pub if EMPTYFLAG
	fail("pkgsize must not more than 500") if pkgsize>500
        pkgs=[]	
	ip=ifip(@intf)
	pkg_arr=tshark_rtfields(filter,efields)	
	if !pkg_arr.nil? && !pkg_arr.empty?					
    	    pkg_arr.each do|item|				
	       pkgs_hash={pub_time: item[FTIME],pub_epoch: item[TIME_EPOCH],msg: item[MQMSG],topic: item[MQTOPIC],ip:ip}
	       pkgs<<pkgs_hash
	       if pkgs.size==pkgsize #当保存的数量达到rsize个写入数据库
	          self.add_pub(pkgs)
		  pkgs=[] #清空
	       end
	   end	
	   self.add_pub(pkgs) unless pkgs.empty?
        else
		msg="#{filter} No packet captured"
 	end		
    end

    # tshark -r mqtt.pcapng -Tfields -e frame.time -e mqtt.msg -e mqtt.topic -e mqtt.msgtype -Y "mqtt.msgtype==3 && ip.src==192.168.10.8"
    #针对revpub，解析报文并保存到数据库
    def revpub_pkg(filter,efields="")	
	      pkg_arr=tshark_rtfields(filter,efields)
	      if !pkg_arr.nil? && !pkg_arr.empty?						
		  pkg_arr.each do|item|
			args={revpub_time:item[FTIME],revpub_epoch:item[TIME_EPOCH]}
			topic=item[MQTOPIC]
			update_pub(topic,args) #update pubs record with the time of  packet recieved 	 						
	          end											           
	     else
	 	  msg="#{filter} No packet captured"
	     end
    end

    # ex_filter,导出报文过滤条件
    # pub_filter,发布消息过滤条件
    # rev_filter,收到布消息过滤条件
    # pub_efields,显示报文哪些字段
    # rev_efields,显示报文哪些字段
    # pkgsize,每个写入数据库的数量
    def write_records(ex_filter,pub_filter,rev_filter,pub_efields="",rev_efields="",pkgsize=300)
      	        src_pkgs=get_pkgfiles()
		src_pkgs.each do |pkgpath|
		    @pkgs=pkgpath
		    #export_pkgs(pkgpath,ex_filter)		
		    pub_pkg(pub_filter,pkgsize,pub_efields)		 
		    revpub_pkg(rev_filter,rev_efields)			 
		end
    end

    # ex_filter,导出报文过滤条件
    # pub_filter,发布消息过滤条件
    # pub_efields,显示报文哪些字段
    # pkgsize,每个写入数据库的数量
    def write_pubs(ex_filter,pub_filter,pkgsize=300,pub_efields="")
                @src_pkgs.each do |pkgpath|
                    @pkgs=pkgpath
                    #export_pkgs(pkgpath,ex_filter)             
                    pub_pkg(pub_filter,pkgsize,pub_efields)
                end
    end

    # ex_filter,导出报文过滤条件
    # rev_filter,收到布消息过滤条件
    # rev_efields,显示报文哪些字段
    # pkgsize,每个写入数据库的数量
    def write_revpubs(rev_filter,pkgsize=300,rev_efields="")
                @src_pkgs.each do |pkgpath|
                    @pkgs=pkgpath
                    revpub_pkg(rev_filter,rev_efields)
                end
    end


    def write_result
	  calculate_delay_epoch
	  result 
    end
  
  end #Tshark

end #ZL 

if __FILE__==$0
   require 'benchmark'
   pkgdir="packets/20170503-160841"
   expdir="packets/20170426-164040/expkgs"
   filename="tsung_mqtt" 
   cap_filter="tcp"
   intf="eth1"
   ex_filter="mqtt.msgtype==3 && (ip.src==192.168.10.31||ip.src==192.168.10.8)"
   pub_filter="mqtt.msgtype==3 && ip.src==192.168.10.31"
   rev_filter="mqtt.msgtype==3 && ip.src==192.168.10.200"
 
  #   Benchmark.bm(7) do |x|
  #  	 x.report("pubs"){ 		
   	    tshark=ZL::Tshark.new(intf)
   	    #tshark.pkgsdir=pkgdir	
	    tshark.pkgs="packets/20170503-160841/tsung_mqtt_00001_20170503160844.pcapng"
	    pp rs=tshark.tshark_rtfields(pub_filter)	
	    #rs=tshark.tshark_rtfields(rev_filter)	
	    #pp rs
            #p rs.size
	    #file=tshark.pub_pkg(pub_filter,300)	
	    #file=tshark.revpub_pkg(rev_filter)	
      
   	    #tshark.pkgsdir=pkgdir	
  #  	    tshark.pkgs_expdir=expdir	
  #	    tshark.write_records(ex_filter,pub_filter,rev_filter)
  #	    tshark.calculate_delay_epoch
 	    #tshark.write_result
	    #tshark.capture(cap_filter,10,1)	
	
  #	 }
  #end

end

