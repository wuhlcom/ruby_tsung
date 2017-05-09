require_relative 'public_methods'
module ZL
	module TsungOpt
		include PubMethods
		
		def tsung_start(xmlpath,logdir="tsung_logs")
			@tsung_log_dir=logdir
		        @tsung_xml=xmlpath
	   	        mk_dir(@tsung_log_dir)
		        system("tsung -f #@tsung_xml -l #@tsung_log_dir start")
		end
	end

	class Tsung

	   include PubMethods 

	   def initialize(xmlpath,logdir="tsungLogs")
	   	    @xmlpath=xmlpath
	   	    @logdir=logdir
	   	    mk_dir(@logdir)
	   end

	   def tsung_start() 
		   system("tsung -f #@xmlpath -l #@logdir start")
	   end

	end #tsung

end #ZL

if __FILE__==$0
   xmlpath="./xmls/mqtt_csv.xml"	
   tsung=ZL::Tsung.new(xmlpath)
   p tsung.tsung_start
end

