class CustomLogger < Logger
 def format_message(severity, timestamp, progname, msg)
    "#{timestamp.to_formatted_s(:db)} #{msg}\n" 
  end 

  def self.wikilog
    @logfile = File.open(File.dirname(__FILE__) + "/../../log/wikilog.log", 'a')    
    @logfile.sync = true
    self.new(@logfile)
  end


  def self.last_entries
    file = File.open(File.dirname(__FILE__) + "/../../log/wikilog.log", 'r')    
    lines = file.readlines[-3..-1]
    lines.reverse! 
  end
end

