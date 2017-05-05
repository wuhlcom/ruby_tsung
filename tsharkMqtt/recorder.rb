#record mqtt packets delay with active records
#author:wuhongliang
#date 2017-03-23
require 'active_record'     
require 'yaml'       

module ZL
  module Recorder 
   yml=File.expand_path("database/database.yml",File.dirname(__FILE__))
   DBCONF = YAML::load(File.open(yml))  
   configuration=DBCONF["mysql"]

   begin
   	 #初始化mysql数据库对象
   	 mysql=ActiveRecord::Tasks::MySQLDatabaseTasks.new(configuration)
   	 #创建数据库
   	 mysql.create
   rescue =>ex 
        ex.message
   end
  
    ActiveRecord::Base.establish_connection(configuration)   
    @@adapter=ActiveRecord::Base.connection


    #判断数据表是否存在，不存在则创建
    unless @@adapter.data_source_exists?(:delays)
      puts "creating table delays....."
      @@adapter.create_table :delays, force: true do |t|       
         t.string  :pub_time 
         t.decimal :delay_time,:precision=>21,:scale=>10
         t.timestamps
      end
    end 
   
    unless !@@adapter.data_source_exists?(:pubs)
      puts "creating table pubs....."
      @@adapter.create_table :pubs, force: true do |t|       
         t.string :pub_time
         t.decimal:pub_epoch,:precision=>21,:scale=>10
         t.string :revpub_time
         t.decimal:revpub_epoch,:precision=>21,:scale=>10
         t.decimal :delay_time,:precision=>21,:scale=>10
         t.text :msg
         t.text :topic
	 t.string :ip 
         t.timestamps
      end 
    end
    
    unless @@adapter.data_source_exists?(:errors)
      puts "creating table errors....."
      @@adapter.create_table :errors, force: true do |t|         
         t.text :msg 
         t.timestamps
      end 
    end
    
    unless @@adapter.data_source_exists?(:results)
      puts "creating table results....."
      @@adapter.create_table :results, force: true do |t| 
         t.decimal :average_delay,:precision=>21,:scale=>10
         t.decimal :maximum_delay,:precision=>21,:scale=>10
         t.decimal :minimum_delay,:precision=>21,:scale=>10
         t.integer :count_delay
         t.timestamps
      end 
    end 

    class Delay < ActiveRecord::Base    
       # establish_connection(configuration)  
       # connection.create_table table_name, force: true do |t|
       #    t.string :clientID
       #    t.time  :pub_time  
       #    t.float :delay_time 
       #    t.timestamps
       # end
       belongs_to :pubs     
    end

    class Pub < ActiveRecord::Base 
        belongs_to :delays  
    end   

    class Error < ActiveRecord::Base    
     
    end

    class Result < ActiveRecord::Base    
     
    end


    def add_pub(args)
        Pub.create!(args)
    end

   def update_pub(topic,args)
          pub = Pub.where(topic: topic) #update pub record
          pub.update(args)   
    end
   
    def add_error(args)
        Error.create!(args)
    end

    def add_result(args)
        Result.create!(args)
    end

    def empty_pub
       Pub.delete_all      
    end
    
    def empty_error
       Error.delete_all      
    end

    def calculate_delays
     # @@adapter.exec_update('update pubs set delay_time=(strftime("%Y%m%d%H%M%f",revpub_time)-strftime("%Y%m%d%H%M%f",pub_time)) where revpub_time is not null')
      @@adapter.execute('update pubs set delay_time=(strftime("%Y%m%d%H%M%f",revpub_time)-strftime("%Y%m%d%H%M%f",pub_time)) where revpub_time is not null')
    end
    
   def calculate_delay_epoch
#      @@adapter.exec_update('update pubs set delay_time=(revpub_epoch-pub_epoch) where revpub_epoch is not null')
      @@adapter.execute('update pubs set delay_time=(revpub_epoch-pub_epoch) where revpub_epoch is not null')
    end

    def result
        avg=Pub.average(:delay_time).to_f
        max=Pub.maximum(:delay_time)
        min=Pub.minimum(:delay_time)
        cnt=Pub.count(:delay_time)
        args={average_delay: avg,maximum_delay: max, minimum_delay: min,count_delay: cnt}
        add_result(args)
    end

  end #Recorder
 end #ZL 

if __FILE__==$0
   require 'bigdecimal'
   epoch = BigDecimal.new("1493889880.589416361")
   include ZL::Recorder
   topic="tsungtopic1"
   args={:pub_time=>epoch}
   update_pub(topic,args) 
end
