require_relative 'public_methods'
module ZL

	class Tsung

	   include PubMethods 

	   def initialize(xmlpath,logdir="logs")
	   	    @xmlpath=xmlpath
	   	    @logdir=logdir
	   		mk_dir(@logdir)
	   end

	   def tsung() 
		   system(tsung -f @xmlpath -l @logdir start)
	   end

	end #tsung

end #ZL

if __FILE__==$0
   include ZL::Tsung
   Tsung.new()
end
