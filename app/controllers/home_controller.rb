require 'twitter'
require 'treat'
require 'tree'

include Treat::Core::DSL



class HomeController < ApplicationController
  
  def index
      
      #function to render the index page
   
  end
  
  def chart
    @positivescore = @@positive_global
    @negativescore = @@negative_global
    @searchterm = @@search_term 
  end
  
  def tweets
    @tweets_print = Array.new
    File.open("app/assets/images/tweetbase.txt", "r") do |f|
         f.each_line do |line|
            puts line
            @tweets_print << line
         end
    end
  end
  
  def result_tweet

       #data read from positive and negative words file
       positivewords = File.read("app/assets/images/poswrds.txt")
       negativewords = File.read("app/assets/images/negwrds.txt")
       tweetbase = File.open("app/assets/images/tweetbase.txt", 'a+')
       tweetgraph = File.open("app/assets/images/tweetgraph.txt", 'a+')
       #stanford nlp pipeline
       pipeline =  StanfordCoreNLP.load(:tokenize, :ssplit, :pos, :lemma, :parse, :ner, :dcoref)   
       @positivecount = 0
       @negativecount = 0
       @netural = 0
       
       #twitter api object definition client is streaming here    
       client = Twitter::REST::Client.new do |config|
      	config.consumer_key        = "2080PXKCT5GkDVlzr6bbA"
      	config.consumer_secret     = "wnIXM0KnT7f1FBaRVhjWlWmoWrsngnoEZJqQmlkTA"
      	config.access_token        = "316601876-07DwuVQa0lWvdd32gyUKbVIjx5tQnLAHNKGE8r1A"
      	config.access_token_secret = "B6PqNOPqSboPaK513RLpsi10ate9MTClOVjj3HHvTXq9G"
      	end     
       
       
       searchterm = "#"+ params[:user_searchterm]
       @@search_term = params[:user_searchterm] 
       puts "*************************************"
       puts "searching for tweets"
       puts "*************************************"
       puts "searchterm:"+searchterm
       puts "*************************************"
       
       #twitter stream ,:result_type => "recent"
       @tweetinput = client.search(searchterm,:lang => "en",:result_type => "mixed").take(2)
             
       #Algorithm for performing sentimental analysis on tweets
       @tweetinput.each do |eachtweet|
       
       tweetbase.write(eachtweet.full_text)
       
       #removing all http RT and user name from the original tweet --> modified tweet
       originaltweet = eachtweet.full_text
       split_originaltweet = originaltweet.split()
       #puts split_originaltweet.class
       #removing using delete
       split_originaltweet.each do |orgtweet|
         
         #remove RT keyword from tweet
         if orgtweet.include? "RT" then
           rtindex = split_originaltweet.index(orgtweet)
           split_originaltweet.delete_at(rtindex)
         end
         
         #remove http links in the tweet
         if orgtweet.include? "http" then
           httpindex = split_originaltweet.index(orgtweet)  
           split_originaltweet.delete_at(httpindex)
         end
         #remove #tags from the tweet
         if orgtweet.include? "#" then
           hashindex = split_originaltweet.index(orgtweet)
           split_originaltweet[hashindex].slice!(0)
         end
         
         if orgtweet.include? "@" then
           atindex = split_originaltweet.index(orgtweet)
           #split_originaltweet[atindex].class
         end        
       
       end
       
       #generating modified tweet
       modifiedtweet = split_originaltweet.join(' ')
       text = modifiedtweet
       #puts text
       #puts "----------------------------------------"
       
       #text processing 
       text = StanfordCoreNLP::Annotation.new(text)
       pipeline.annotate(text)
       
            text.get(:sentences).each do |sentence|
               
               #create a tree
               startvertex = "{#{searchterm} => {}}"
               # create two child nodes 
               @graph = [startvertex] 
               @sentiment_array = Array.new()
               # Syntatical dependencies
               #puts sentence.get(:basic_dependencies).to_s
               counter = 0
               sentence.get(:tokens).each do |token|
                      
                      tokenstring = token.get(:value).to_s
                      pos = token.get(:part_of_speech).to_s
                      #constructions of nodes
                      #puts !(searchterm.include?(tokenstring))
                      if !(searchterm.include?(tokenstring)) 
                         
                         #puts "working"
                         if (pos == "JJ"||pos == "JJR"||pos == "JJS") then
                           #check whether positive or not
                                                                     
                           if positivewords.include? tokenstring then
                              @positivecount += 1
                              #@graph << "positive"
                              #@sentiment_array.push("positive")
                              newadjvertex = "{#{tokenstring} => {#{searchterm} => [#{pos},1]}}"
                              tweetbase.write(" => positive")
                              @graph << newadjvertex
                           elsif  negativewords.include? tokenstring then
                              @negativecount = @negativecount + 1
                              #@graph << "negative"
                              #@sentiment_array.push("negative")
                              tweetbase.write(" => negative")
                              newadjvertex = "{#{tokenstring} => {#{searchterm} => [#{pos},-1]}}"
                              @graph << newadjvertex
                           else
                                #puts "netural"
                                #@graph << "negative"
                                @negativecount += 1
                                #@sentiment_array.push("negative")
                                tweetbase.write(" => negative")
                                newadjvertex = "{#{tokenstring} => {#{searchterm} => [#{pos},-1]}}"
                                @graph << newadjvertex
                           end 
                           #adding the adjective node
                              @graph.each do |vertex|
                                    vertex.sub(":adjective",tokenstring)
                              end #graph end           
                         
                         else
                           newvertex = "{#{tokenstring} => {:adjective => [#{pos},0]}}"
                           @graph << newvertex
                           #puts newvertex 
                         end#to check whether adjective or not
                      end #if not root
                      
              end
              
           end
         #puts @sentiment_array
         #puts @graph
         tweetbase.write("\n")
         tweetgraph.write(@graph)
         tweetgraph.write("\n")
         
         #puts "##################"
       end
   tweetbase.close()
   tweetgraph.close()    
   puts @positivecount
   puts @negativecount
   @@positive_global = @positivecount
   @@negative_global = @negativecount    
   @@tweet_base = @text
   @text = @tweetinput
   @text
   render layout: false
      
  end

end
