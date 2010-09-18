class FeedUpdater < Post 
  require 'feedzirra'

 def self.check_if_bgprocess_running
    $running = false
    test = `ps ef | grep -v grep | grep FeedUpdater` 
    $running = true if test.length > 0
  end


 def self.update_feeds_cron
   @logfile = File.open(File.dirname(__FILE__) + "/../../log/feed_updater.log", 'a')    
   @logfile.sync = true
   @feed_updater_log = CustomLogger.new(@logfile) 
   @feed_updater_log.info("Starting updating feeds")
   feeds_array = update_feed_addresses

    feeds_array.each do |feed| 
      begin
      feed = Feedzirra::Feed.update(feed)
        if feed.updated?   
          feed2 = Feedzirra::Feed.fetch_and_parse(feed.feed_url)   
          @feed_updater_log.info("Updated from: " + feed.feed_url)
          user = User.find_by_blog_url(feed.feed_url)
          add_entries(feed.new_entries, user)
          feeds_array.delete(feed)
          feeds_array.push(feed2)
          loop_and_update(feeds_array)
        end
      rescue Exception => e
        error_count = error_count + 1
        @feed_updater_log.error("Exception in subsequent update : " + e.message + " " + feed.to_s)
      end
    end   
 end


 def self.update_feeds   
   @logfile = File.open(File.dirname(__FILE__) + "/../../log/feed_updater.log", 'a')    
   @logfile.sync = true
   @feed_updater_log = CustomLogger.new(@logfile) 
   @feed_updater_log.info("Starting updating feeds")
   feeds_array = update_feed_addresses
   loop_and_update(feeds_array)
 end

 def self.update_feed_addresses
  feeds_array = Array.new
  users = User.find(:all, :conditions => "blog_url != ''")
  users.each do |user| 
     begin 
       feed = Feedzirra::Feed.fetch_and_parse(user.blog_url)   
       add_entries(feed.entries, user) 
       feeds_array << feed
     rescue Exception => e 
        @feed_updater_log.error("Exception: " + e.message + " " + user.blog_url)
        @feed_updater_log.error( e.backtrace )
     end
  end
  feeds_array
 end

 def self.loop_and_update(feeds_array)
   loop_count = 0
   error_count = 0
   loop do
    puts "trying to update" + loop_count.to_s
    @feed_updater_log.info("trying to update" + loop_count.to_s)
      feeds_array.each do |feed| 
        begin
        feed = Feedzirra::Feed.update(feed)
          if feed.updated?   
            feed2 = Feedzirra::Feed.fetch_and_parse(feed.feed_url)   
            @feed_updater_log.info("Updated from: " + feed.feed_url)
            user = User.find_by_blog_url(feed.feed_url)
            add_entries(feed.new_entries, user)
            feeds_array.delete(feed)
            feeds_array.push(feed2)
            loop_and_update(feeds_array)
          end
        rescue Exception => e
          error_count = error_count + 1
          @feed_updater_log.error("Exception in subsequent update : " + e.message + " " + feed.to_s)
        end
      end   
    loop_count = loop_count + 1
    #is there is some repetitive error, try starting from the beginning
    if error_count > 10
      @feed_updater_log.info("10 Exceptions counted, restarting")
      update_feeds 
    end
    #once in a while we should check for new feeds. Unfortunately this means we have to go through all feeds and update them
    update_feeds if loop_count > 10 
    sleep 300 
  end
 end   

def self.add_entries(entries, user)
      entries.each do |entry|   
    unless exists? :guid => entry.id   
#       if title is null (like all of my blog entries)
        entry.title = entry.id unless entry.title
        entry.content = entry.content ||= entry.summary
        Post.create!(   
          :title      => entry.title.slice(0, 96) + (entry.title.length > 96 ? "..." : ""),   
          :body       => entry.content + " ",   
          #fix for Goethe institut - they set published date to the day of event - not fair!
          :created_at => entry.published > Time.now + 1.day ? Time.now : entry.published
          :user_id    => user.id,
          :from_url   => entry.url,
          :guid       => entry.id,
          :cached_tag_list => entry.categories.join(","), 
          :updating_feed => true
        )   
      end   
    end
  end
end

