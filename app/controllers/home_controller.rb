require "rubygems"
require "twitter"



class HomeController < ApplicationController
  

  
  
  def index
      
   puts "hi123"

    
  
    

  	
        
        

    #puts client.search("#ruby -rt", :lang => "en").first.text

  end

  def result_tweet

   #twitter api object definition client is streaming here    
   client = Twitter::REST::Client.new do |config|
  	config.consumer_key        = "2080PXKCT5GkDVlzr6bbA"
  	config.consumer_secret     = "wnIXM0KnT7f1FBaRVhjWlWmoWrsngnoEZJqQmlkTA"
  	config.access_token        = "316601876-07DwuVQa0lWvdd32gyUKbVIjx5tQnLAHNKGE8r1A"
  	config.access_token_secret = "B6PqNOPqSboPaK513RLpsi10ate9MTClOVjj3HHvTXq9G"
  	end     
   
   
   searchterm = params[:user_searchterm]  
   puts "*************************************"
   puts "searching for tweets"
   puts "*************************************"
   topics = ["coffee", "tea"]
   i=0
   n=10
   #while i < n do
    #client.filter(:track => searchterm, :lang => "en") do |object|
     #if i< n then     
     #puts object.text if object.is_a?(Twitter::Tweet)
     #i+=1
     #end
     #end
   #end
   @text = "</br>"
   while i < n do    
   @text = @text + client.search(searchterm, :lang => "en").first.text + "</br>"
   i+=1
   end
   @text
   #render inline: "<%= @testtext %>"
   render layout: false
      
  end

end
