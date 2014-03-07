require "rubygems"
require "twitter"



class HomeController < ApplicationController
  def index
      
   puts "hi123"

    
  
    

  	client = Twitter::REST::Client.new do |config|
  	config.consumer_key        = "2080PXKCT5GkDVlzr6bbA"
  	config.consumer_secret     = "wnIXM0KnT7f1FBaRVhjWlWmoWrsngnoEZJqQmlkTA"
  	config.access_token        = "316601876-07DwuVQa0lWvdd32gyUKbVIjx5tQnLAHNKGE8r1A"
  	config.access_token_secret = "B6PqNOPqSboPaK513RLpsi10ate9MTClOVjj3HHvTXq9G"
  	end
        
        

        puts client.search("#ruby -rt", :lang => "en").first.text

  end

  def hi

   require "rubygems"
   require "twitter"
   
   puts "hi"

   puts Twitter.user("akrish2011").location
  end
end
