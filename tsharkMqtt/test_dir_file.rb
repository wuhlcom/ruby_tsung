def get_pkgfiles(path,filename)
  	files=[]
  	files=Dir.glob("#{path}/*").select{|file|	file =~ /#{filename}/}	
end

path="captures"
filename="mqtt"
p get_pkgfiles(path,filename)