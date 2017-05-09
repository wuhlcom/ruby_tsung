require_relative 'public_methods'
require "rexml/document"

module ZL

	class TsungXML
		include ZL::PubMethods 
		COMMENT = '<?xml version="1.0"?>'
		attr_accessor :doc, :root_el
		def initialize()
		    @xmldir=xmldir
	   		mk_dir(xmldir)
			@doc     = REXML::Document.new #创建XML内容
			@root_el = @doc.add_element("WLANProfile")
		end
	end #XML
       
       module ParseXML
         
	  #读取xml
         def open_xml(xmlpath)
	     @xmlpath=xmlpath
	     @xmlfile = File.open(@xmlpath,"r")
         end
    
         def xmlobj(xmlpath)
             open_xml(xmlpath)
             @xml=REXML::Document.new(@xmlfile)
	 end
	 
	 #找到第一个client节点
	 def change_client_node(hostname,ip,maxusers=40000)
	     @flag=false 
	     @xml.elements.each("//client")do |e| 
                host=e.attributes["host"]
                maxusesrs=e.attributes["maxusers"]
	        ip_addr=e.elements["ip"].attributes["value"]
                if host!=hostname	
                   @flag=true 
                   e.attributes["host"]=hostname	
                end

                if host!=maxusers	
                    @flag=true||@flag 
                    e.attributes["maxusers"]=maxusers	
                end 
	     
 	        if ip_addr!=ip #修改ip地址
	           e.elements["ip"].attributes["value"]=ip #修改ip地址
		   @flag=true||@flag
	         end
    	     end
	 end

         def save_xml()
	     @xmlfile2 = File.open(@xmlpath,"w")
	     @xmlfile2.puts xml.write(STDOUT,2) #保存修改后的xml
	 end

	 def close_xml
              @xmlfile.close	    
	 end

         def close_xml2
	     @xmlfile2.close
         end

         def change_client(xmlpath,hostname,ip,maxusers=40000)
	     xmlobj(xmlpath)
             change_client_node(hostname,ip,maxusers)
	     if @flag
	    	 save_xml
	     	 close_xml2
	     end
	     close_xml
	 end 
       
      end #ParseXMl

end #ZL
