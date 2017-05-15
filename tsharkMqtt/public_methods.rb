require 'fileutils'
require 'pp'
module ZL
      module PubMethods

        def mk_dir(dir)
		unless File.exists?(dir)
	    	   FileUtils.mkdir_p(dir)  
	    	end
        end

        def ifip(intf="eth0")
	    rs=`ifconfig #{intf}`
	    #inet addr:192.168.10.166  Bcast:192.168.10.255  Mask:255.255.255.0
	    rs.slice(/inet\s+addr:(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+Bcast:/,1)
       end

       def psef(cmd="tshark")
          #print `ps -ef|grep #{cmd}|grep -v grep`
          pidstr=`ps -ef|grep #{cmd}|grep -vE 'grep|vim|ruby'|awk -F " " '{print $2}'`
	  pids=pidstr.split("\n")
       end
	
       def linuxkill(pid)
	   `sudo kill -9  #{pid}`
       end

       def linuxpkill(cmd="tshark")
	   `sudo pkill -9 #{cmd}`
       end
	
       def whoami
	    rs=`whoami`.delete("\n")
       end

       def hostname
	   rs=`hostname`.delete("\n")
       end

       def uid()
	    `id -u #{whoami}`.delete("\n")
       end
 	
       def gid()
	   `id -g #{whoami}`.delete("\n")
       end
	
       def chown_R(file)
	   usr=whoami
	   `sudo chown -R  #{usr}:#{usr} #{file}`
      end

      def chmod_R(mode,file)
           `sudo chmod -R #{mode} #{file}` 	 
      end
	
      #创建指定长度的id
      def create_id(id_pre,index,id_size=16)
           id_pre_size=id_pre.size
           index_size=index.to_s.size
           if id_pre_size<id_size
              zero_num=id_size-id_pre_size-index_size
              zeros="0"*zero_num
              id=id_pre+zeros+index.to_s
           elsif id_pre_size==id_size
              id_pre[-id_size..-1]=index.to_s
             id=id_pre
           else
              puts "ID config error!"
           end
        end


   end #PubMethods
end #ZL

if __FILE__==$0
    include ZL::PubMethods
    #ifip
   # cmd="tshark"
   # p psef(cmd)
   # linuxpkill
   # p psef(cmd)
  p uid
  p gid
  chown_R("./packets")  
end
