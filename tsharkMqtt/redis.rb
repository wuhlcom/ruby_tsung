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

        def hmset_file(num,ip,id_pre,usr,pw,filename="redis_accounts.txt",port="6379",type="tjWqnmM2j3APn4Mo")
	    @redis_dir="redis_accounts"
	    mk_dir(@redis_dir)
	    @redis_accfile="redis_accounts/#{filename}"
	    File.open(@redis_accfile,"w+") do|file|
		num.times.each do |number|
		    #file.puts "hmset CINFO:'#{id_pre}#{number}' USER #{usr} PASSWD #{pw}"
		    id=create_id(id_pre,number)
		    file.puts "hmset CINFO:#{id} USER #{usr} PASSWD #{pw} TYPE #{type} ID #{id}"
		end
	    end
	end
	
	def hmset_batch(ip,port="6379")
	    `redis-cli -h #{ip} -p #{port} < #{@redis_accfile} >> "#{@redis_dir}/redis_accounts.log"`
	end
	
	def hmset_accounts(num,ip,id_pre,usr,pw,filename="redis_accounts.txt",port="6379")
        	 hmset_file(num,ip,id_pre,usr,pw,filename,port)
		 hmset_batch(ip,port)
	end
       
    end #Redis
end #ZL

if __FILE__==$0
   include ZL::Redis
   num=10
   ip="192.168.10.200"
   ip="192.168.10.8"
   id_pre="wuhongliang"
   usr="mqttclient"
   pw="mqttclient"
   hmset_accounts(num,ip,id_pre,usr,pw)
   p hgetall(ip,"wuhongliang00001")
end
