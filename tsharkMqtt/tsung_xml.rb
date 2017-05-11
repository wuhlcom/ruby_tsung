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

	 def change_load_node(sub_phase_duration,sub_users_maxnum,pub_phase_duration,sub_phase_unit="second",sub_users_arrivalrate="50",sub_users_unit="second")
                pub_phase_unit=sub_phase_unit
                pub_users_arrivalrate=sub_users_maxnum
                pub_users_maxnum=sub_users_maxnum
                pub_users_unit=sub_users_unit
		@load_flag=false
                #############sub#############################
                sub_arrivalphase=@xml.root.elements["load"].elements[1,"arrivalphase"]

		if sub_arrivalphase.attributes["duration"]!=sub_phase_duration
	                sub_arrivalphase.attributes["duration"]=sub_phase_duration
			@load_flag=true
	        end
                sub_arrivalphase.attributes["unit"]=sub_phase_unit

                sub_users=sub_arrivalphase.elements["users"]
                sub_users.attributes["arrivalrate"]=sub_users_arrivalrate
                if sub_users.attributes["maxnumber"]!=sub_users_maxnum
	                sub_users.attributes["maxnumber"]=sub_users_maxnum
			@load_flag=true||@load_flag
		end
                sub_users.attributes["unit"]=sub_users_unit
                ##################pub#################
                pub_arrivalphase=@xml.root.elements["load"].elements[2,"arrivalphase"]
		if pub_arrivalphase.attributes["duration"]!=pub_phase_duration
                	pub_arrivalphase.attributes["duration"]=pub_phase_duration
			@load_flag=true||@load_flag
		end
                pub_arrivalphase.attributes["unit"]=pub_phase_unit

                pub_users=pub_arrivalphase.elements["users"]
                pub_users.attributes["arrivalrate"]=pub_users_arrivalrate
                pub_users.attributes["maxnumber"]=pub_users_maxnum
                pub_users.attributes["unit"]=pub_users_unit
   end

         def save_xml()
	     @xmlfile2 = File.open(@xmlpath,"w")
	     @xmlfile2.puts @xml.write(STDOUT,2) #保存修改后的xml
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
         
	def chang_xml(xmlpath,hostname,ip,sub_duration,pub_duration,sub_num,maxusers="40000",sub_phase_unit="second",sub_users_arrivalrate="50",sub_users_unit="second") 
	    xmlojb(xmlpath)
	    change_client_node(hostname,ip,maxusers)
	    change_load_node(sub_duration,sub_num,pub_duration,sub_phase_unit,sub_users_arrivalrate,sub_users_unit)
	     if @flag||@load_flag
	    	 save_xml
	     	 close_xml2
	     end
	     close_xml
	end

      end #ParseXMl

end #ZL

if __FILE__==$0
  include ZL::ParseXML
  xmlpath="./xmls/mqtt_csv.xml"
  hostname="zhilu"
  ip="192.168.10.31"
  change_client(xmlpath,hostname,ip)

end
