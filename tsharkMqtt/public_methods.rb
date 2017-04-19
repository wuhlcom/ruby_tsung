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

	def uid()
	    `id -u #{whoami}`.delete("\n")
	end
 	
	def gid()
	   `id -g #{whoami}`.delete("\n")
	end
	
	def chown(file)
	   usr=whoami
	   `sudo chown -R  #{usr}:#{usr} #{file}`
	end

	def chmod(file)
	 
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
end
