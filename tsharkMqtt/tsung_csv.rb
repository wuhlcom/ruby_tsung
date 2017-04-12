require 'csv'

class MqttCSV
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

   def initialize(path)
       @csv_path=path
   end
   
  # Writing
  # To a File
  def tsung_csv(s,e,args)
    CSV.open(@csv_path, "wb") do |csv|
 	for i in s..e
    	 csv << args.map{|item|"#{item}#{i}"}
        end 
    end
  end

end
 #ruby tsung_csv.rb create_csv sub.csv 1 1000 tsungSub tsungTopic 
 #ruby tsung_csv.rb create_csv pub.csv 1 1000 tsungPub tsungTopic hello 
 index=ARGV.size-1
 if ARGV[0]=="create_csv"
    csv_path=ARGV[1]
    sid=ARGV[2]
    eid=ARGV[3]
    args=ARGV[4..index]
    mqttcsv=MqttCSV.new(csv_path)
    mqttcsv.tsung_csv(sid,eid,args)
  else
    puts "ARGV 0 Error"
  end 
