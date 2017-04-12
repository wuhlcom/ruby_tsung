require_relative 'public_methods'
require "rexml/document"

module ZL
	class XML
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
end #ZL