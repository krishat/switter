require 'rubygems'
require 'twitter'
require 'treat'

include Treat::Core::DSL

class HomeController < ApplicationController
  

  
  
  def index
      
      #function to render the index page
   
  end
  
  
  def result_tweet

       #stanford nlp pipeline
       pipeline =  StanfordCoreNLP.load(:tokenize, :ssplit, :pos, :lemma, :parse, :ner, :dcoref)   
       
       
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
       
       #twitter stream
       @tweetinput = client.search(searchterm,:lang => "en",:result_type => "recent").take(15)
       @tweetinput.each do |tweet|
       puts tweet.text
       end
       
       #Algorithm for performing sentimental analysis on tweets
       @tweetinput.each do |eachtweet|
       
       #removing all http RT and user name from the original tweet --> modified tweet
       originaltweet = eachtweet.full_text
       split_originaltweet = originaltweet.split()
       #removing using delete
       split_originaltweet.each do |orgtweet|
         if orgtweet =~ /^http|^RT|^\@$/i then
           split_originaltweet.delete(orgtweet)
         end
       end
       
       #generating modified tweet
       modifiedtweet = split_originaltweet.join(' ')
       text = modifiedtweet
       puts text
       puts text.class
       
       #text processing 
       text = StanfordCoreNLP::Annotation.new(text)
       pipeline.annotate(text)
    
            text.get(:sentences).each do |sentence|
               # Syntatical dependencies
               #puts sentence.get(:basic_dependencies).to_s
               sentence.get(:tokens).each do |token|
                      # Default annotations for all tokens
                      #puts token.get(:value).to_s
                      #puts token.get(:original_text).to_s
                      #puts token.get(:character_offset_begin).to_s
                      #puts token.get(:character_offset_end).to_s
                      # POS returned by the tagger
                      puts token.get(:part_of_speech).to_s
                      # Lemma (base form of the token)
                      #puts token.get(:lemma).to_s
                      # Named entity tag
                      #puts token.get(:named_entity_tag).to_s
                      # Coreference
                      #puts token.get(:coref_cluster_id).to_s
                      # Also of interest: coref, coref_chain, 
                      # coref_cluster, coref_dest, coref_graph.
              end
           end
         
         
         
       end
   @text = @tweetinput
   @text
   render layout: false
      
  end

end
