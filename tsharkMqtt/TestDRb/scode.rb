# This example illustrates returning a reference to an object from a dRuby call. 
# The Logger instances live in the server process. 
# References to them are returned to the client process, where methods can be invoked upon them. 
# These methods are executed in the server process.
#在服务端的进程执行，但客户端创建了日志文件
require 'drb/drb'

#URI="druby://localhost:8787"
URI="druby://192.168.10.166:8787"

class Logger

    # Make dRuby send Logger instances as dRuby references,
    # not copies.
    include DRb::DRbUndumped

    def initialize(n, fname)
        @name = n
        @filename = fname
    end

    def log(message)
        File.open(@filename, "a") do |f|
            f.puts("#{Time.now}: #{@name}: #{message}")
        end
    end

end

# We have a central object for creating and retrieving loggers.
# This retains a local reference to all loggers created.  This
# is so an existing logger can be looked up by name, but also
# to prevent loggers from being garbage collected.  A dRuby
# reference to an object is not sufficient to prevent it being
# garbage collected!
class LoggerFactory

    def initialize(bdir)
        @basedir = bdir
        @loggers = {}
    end

    def get_logger(name)
        if !@loggers.has_key? name
            # make the filename safe, then declare it to be so
            fname = name.gsub(/[.\/\\:]/, "_").untaint
            @loggers[name] = Logger.new(name, @basedir + "/" + fname)
        end
        return @loggers[name]
    end

end

dir="d:/tmp/dlog"
dir="/tmp/dlog"
FRONT_OBJECT=LoggerFactory.new(dir)

$SAFE = 1   # disable eval() and friends

DRb.start_service(URI, FRONT_OBJECT)
DRb.thread.join

