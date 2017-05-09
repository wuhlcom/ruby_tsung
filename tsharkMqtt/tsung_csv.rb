require 'csv'

module ZL

 module TsungCSV
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
  def tsung_csv(csv_path,num,*args)
    CSV.open(csv_path, "wb") do |csv|
 	num.times.each do|i|
    	 csv << args.map{|item|"#{item}#{i}"}
        end 
    end
  end

  end #TsungCSV

end #zl


if __FILE__==$0
 include ZL::TsungCSV
 csv_path="csvs/sub.csv"
 sid=1
 eid=1000
 subject="test"
 topic="tsungTopic"
 tsung_csv(csv_path,eid,subject,topic)
end
