require_relative 'public_methods'
module ZL

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

