require 'csv'
require_relative 'public_methods'
module ZL

 module TsungCSV
   include PubMethods
   # Reading
   #  From a File
   
   # # A Line at a Time
   # CSV.foreach("path/to/file.csv") do |row|
   #   # use row here...
   # end
   
   # # All at Once
   # arr_of_arrs = CSV.read("path/to/file.csv")
   
   # From a String
   # # A Line at a Time
   # CSV.parse("CSV,data,String") do |row|
   #   # use row here...
   # end
   
   # # All at Once
   # arr_of_arrs = CSV.parse("CSV,data,String")
   
  # Writing
  # To a File
  def tsung_csv(csv_path,num,id_pre,*args)
    csv_dir=File.dirname(csv_path)
    mk_dir(csv_dir)
    CSV.open(csv_path, "wb") do |csv|
 	num.times.each do|i|
              id=create_id(id_pre,i)
    	      new_args=args.map{|item|"#{item}#{i}"}
              values=new_args.unshift(id)
    	      csv << values
        end 
    end
  end

  end #TsungCSV

end #zl


if __FILE__==$0
 include ZL::TsungCSV
 csv_path="csvs/sub.csv"
 num=1000
 subject="testsubject"
 id_pre="testsubid"
 topic="tsungTopic"
 tsung_csv(csv_path,num,id_pre,topic)
end
