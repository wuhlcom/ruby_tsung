#zhilu@zhilu-ubuntu02:~$ redis-cli -h 192.168.10.200 hmset CINFO:whl01 USER mqttlclienSWD mqttclient
#OK
#zhilu@zhilu-ubuntu02:~$ redis-cli -h 192.168.10.200 hgetall CINFO:whl01
#1) "USER"
#2) "mqttlclient"
#3) "PASSWD"
#4) "mqttclient"
# install redis-client:
# sudo apt-get install redis-tools -y
# create redis date -->new 2017-05-15
# hmset CINFO:test111111111111 GROUP 112344555: USER test PASSWD test TYPE tjWqnmM2j3APn4Mo ID test111111111111
require_relative 'public_methods'
module ZL
    module Redis
	include PubMethods

	def hmset_account(ip,id,usr,pw,port="6379")
		`redis-cli -h #{ip} -p #{port} hmset CINFO:#{id} USER #{usr} PASSWD #{pw}`
	end

        def hgetall(ip,id,port="6379")
		rs=`redis-cli -h #{ip} -p #{port} hgetall CINFO:#{id}`
		rs.split("\n")
	end

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

        def hmset_file(num,ip,id_pre,usr,pw,filename="redis-accounts.txt",port="6379")
	    @redis_dir="redis_accounts"
	    mk_dir(@redis_dir)
	    @redis_accfile="redis_accounts/#{filename}"
	    File.open(@redis_accfile,"w+") do|file|
		num.times.each do |number|
		    #file.puts "hmset CINFO:'#{id_pre}#{number}' USER #{usr} PASSWD #{pw}"
		    id=create_id(id_pre,number)
		    file.puts "hmset CINFO:'#{id}' USER #{usr} PASSWD #{pw}"
		end
	    end
	end
	
	def hmset_batch(ip,port="6379")
	    `redis-cli -h #{ip} -p #{port} < #{@redis_accfile} >> "#{@redis_dir}/redis-acc-log.log"`
	end
	
	def hmset_accounts(num,ip,id_pre,usr,pw,filename="redis-accounts.txt",port="6379")
        	 hmset_file(num,ip,id_pre,usr,pw,filename,port)
		 hmset_batch(ip,port)
	end
       
    end #Redis
end #ZL

if __FILE__==$0
   include ZL::Redis
   num=10
   ip="192.168.10.200"
   id_pre="wuhongliang"
   usr="mqttclient"
   pw="mqttclient"
   hmset_accounts(num,ip,id_pre,usr,pw)
   p hgetall(ip,"wuhongliang00001")
end
