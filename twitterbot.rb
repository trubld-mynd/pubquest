require 'rubygems'
require 'oauth'
require 'json'
require 'time'
require 'date'

require 'clockwork'
require './config/boot'
require './config/environment'

$t_end = Time.new(2014,9,12,20,00,0,"+10:00")

class TwitterDM
    def initialize()
        t = Time::new
        
    $directmessages = ["Welcome to Snakes N Ladders Pub Quest! I am the Pub Questbot. Tweet your drink count at each pub (max 4) *AND A PHOTO* to me @pubquestbot",
        "E.g. if your team has had 3 drinks, take a photo of your team with the drinks, and tweet '@pubquestbot 3 drinks'. Don't forget the pic!",
        "You move will be determined by your 'dice roll' (your drink count +/-1). E.g. your 3 drinks might move you 2,3 or 4 spaces on the board!",
        "I will then tell you where to go (If you land on a snake/ladder, I'll send you straight to the bottom/top of it).",
        "I'll only accept tweets every 20 minutes. After 20 mins has past, you have a 15 minute window for your next tweet to be read & dice rolled.",
        "The winner will be the first to roll on to Frankie's, OR the team that gets the furtherest in 2.5 hours.",
        "Check out the Snakes N Ladders map at the website http://www.pubquest.info",
        "LET THE GAMES BEGIN!",
        "The pubquest is over! Come to Frankie's Pizza (Pub 30) to celebrate & party with the winners!"]

## Verify connection to Twitter API
consumer_key = OAuth::Consumer.new(
"lZLYSIi4dbgIN9yRzTcIeP8Fk",
"3BqN9Qz9iVdYpPKJxXR0hjuaC1KXXPc03lIv02PyZGnXo5CRhR")
access_token = OAuth::Token.new(
"2776153651-zpSsnVPbMUhl34fWK2DdCmAhc2kG41aDPaZxiBP",
"yiXJmkrdheEi4PNGu4IS7WcX1tC9y9hDR06EFqOtIg2Gg")
baseurl = "https://api.twitter.com"

## Run the following script for each message 
## in the $directmessages array above
message_to_tweet = nil
$directmessages.each do |message|

    ## Search past pubquestbot tweets for direct messages
    ## Using the same search method as to establish
    ## users past pub instructions
    firstpath = "/1.1/statuses/user_timeline.json"
    firstquery = URI.encode_www_form(
        "screen_name" => "pubquestbot",
        "count" => 200,
        )
    firstaddress = URI("#{baseurl}#{firstpath}?#{firstquery}")
    request = Net::HTTP::Get.new firstaddress.request_uri

    http             = Net::HTTP.new firstaddress.host, firstaddress.port
    http.use_ssl     = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    request.oauth! http, consumer_key, access_token
    http.start
    response = http.request request

    pasttweets = nil
    if response.code == '200' then
      pasttweets = JSON.parse(response.body)
        pasttweets.reverse_each do |pasttweet|
        
        ## set message_to_tweet if don't find message in pasttweets
        message_to_tweet = case message
        when pasttweet then break
        when $directmessages.last.to_s then message if t > $t_end || $users_score.has_value?(30)
        else message
        # end of message_to_tweet case
        end 

        # end of bottweets.reverse_each
        end
    # end of response.code == '200'
    end    

## Post direct tweets for pubquest instructions
## Use same script for outgoing Tweets
## As section 3 of the search & tweet.

            thirdpath    = "/1.1/statuses/update.json"
            thirdaddress = URI("#{baseurl}#{thirdpath}")
            request = Net::HTTP::Post.new thirdaddress.request_uri
            request.set_form_data(
              "status" => message_to_tweet,
            )
            
            # Set up HTTP.
            http             = Net::HTTP.new thirdaddress.host, thirdaddress.port
            http.use_ssl     = true
            http.verify_mode = OpenSSL::SSL::VERIFY_PEER
            
            # Issue the request.
            request.oauth! http, consumer_key, access_token
            http.start
            response = http.request request
            
            # Parse and print the Tweet if the response code was 200
            tweet = nil
            if response.code == '200' then
              tweet = JSON.parse(response.body)
              puts "Successfully sent #{tweet["text"]}"
            else
              puts "Could not send the Tweet! " +
              "Code:#{response.code} Body:#{response.body}"
            end
            sleep 3
        # end of $directmessages.each do |message|
        end
    # end of def initialize()
    end
# end of class TwitterDM 
end
#####################################
#####################################
#####################################
class TwitterTweet
    def initialize()

t = Time::new
puts t

## Establish Users
 
names = ["PoisonSlammers", "TheWindSlayers", "PurpleSquirels", "TheGhostSharks", "MightyCommandos", "DreamLightning"]
users_list = Hash[names.map{|user| [user, 0]}]
$users_score = Hash[names.map{|user| [user, 0]}]
$users_last_time = Hash[names.map{|user| [user, 0]}]
users_last_location = Hash[names.map{|user| [user, 0]}]

## Verify connection to Twitter API
consumer_key = OAuth::Consumer.new(
"lZLYSIi4dbgIN9yRzTcIeP8Fk",
"3BqN9Qz9iVdYpPKJxXR0hjuaC1KXXPc03lIv02PyZGnXo5CRhR")
access_token = OAuth::Token.new(
"2776153651-zpSsnVPbMUhl34fWK2DdCmAhc2kG41aDPaZxiBP",
"yiXJmkrdheEi4PNGu4IS7WcX1tC9y9hDR06EFqOtIg2Gg")
baseurl = "https://api.twitter.com"

## Establish Keywords
keywords = ["pubquestbot", "drinks"]

## Establish Bar Locations
bars = [0,1,4,3,4,6,6,7,11,13,7,11,12,13,14,12,20,17,18,19,20,17,22,27,24,25,24,27,28,28,30]
barnames = ["Start", "Sweeny's", "Grandma's", "Cuban", "99onYork", "The Rook", "Barbershop", "SG's", "Forbes", "PJs", "CBD", "Le Pub", "Mojo", "Bavarian", "Stitch", "Uncle Ming's", "Steel Br & Grill", "GPO Bar", "Angel Hotel", "Ivy (or Felix/Ash St)", "Royal George", "Establish", "Metropolitan", "Mr Wong's", "BridgeSt", "Republic", "Tank", "Palmer & Co", "Ryans", "Grand Hotel", "Frankies"]
barsnls = ["Start","Go on to ", "LADDER! Go straight to ", "Go on to ", "Go on to ", "LADDER! Go straight to ", "Go on to ", "Go on to ", "LADDER! Go straight to ", "LADDER! Go straight to ", "SNAKE! Go back to ", "Le stop at ", "Party on to ", "Go on to ", "Pop into ", "SNAKE! Go back to ", "LADDER! Go straight to ", "Head down to ", "Go on to ", "Have a drink around ", "Stop in at ", "SNAKE! Go back to ", "Go on to ", "LADDER! Go straight to ", "Tune up at ", "Party on to ", "SNAKE! Go back to ", "Nearly there! Go on to ", "Nearly there! Go on to ", "SNAKE! (So close!) Go back to ", "You made it! Go to "]


## Get User current position from Pubquestbot's 
## previous instruction tweets 

firstpath = "/1.1/statuses/user_timeline.json"
locationquery = URI.encode_www_form(
    "screen_name" => "pubquestbot",
    "count" => 20,
    )
firstaddress = URI("#{baseurl}#{firstpath}?#{locationquery}")
request = Net::HTTP::Get.new firstaddress.request_uri

http             = Net::HTTP.new firstaddress.host, firstaddress.port
http.use_ssl     = true
http.verify_mode = OpenSSL::SSL::VERIFY_PEER

request.oauth! http, consumer_key, access_token
http.start
response = http.request request

bottweets = nil
if response.code == '200' then
  bottweets = JSON.parse(response.body)
    bottweets.reverse_each do |bottweet|
    puts bottweet["user"]["name"] + " - " + bottweet["text"]
    ## Identify User from bottweet
    to_user = bottweet["in_reply_to_screen_name"]
    to_user_freeze = to_user.freeze
    if to_user != nil && to_user != ""
        ## SPLIT TWEET UP INTO WORDS 
        botwords = bottweet["text"].to_s.split(" ")
        lastpub = botwords.last.to_i
        $users_score[to_user_freeze] = lastpub
    # if to_user != nil
    end
    # end of bottweets.reverse_each
    end
# end of response.code == '200'
end

puts "users_score = " + $users_score.to_s

## Run the search & tweet script for all 
## users in the user_list

users_list.each do |name, number|
    puts "New loop: " + name
    name_freeze = name.freeze
## Search User Timelines

secondpath = "/1.1/statuses/user_timeline.json"
userquery = URI.encode_www_form(
    "screen_name" => name,
    "count" => 15,
    )
secondaddress = URI("#{baseurl}#{secondpath}?#{userquery}")
request = Net::HTTP::Get.new secondaddress.request_uri

http             = Net::HTTP.new secondaddress.host, secondaddress.port
http.use_ssl     = true
http.verify_mode = OpenSSL::SSL::VERIFY_PEER

request.oauth! http, consumer_key, access_token
http.start
response = http.request request

tweets = nil
tweet_t = nil
if response.code == '200' then
  tweets = JSON.parse(response.body)
    tweets.reverse_each do |tweet|
        $tweetout = nil
        rollcount = 0
        rollout = Array.new
        $tweetout = Array.new        
        ## Get tweet location (if available) and push to 
        ## users_last_location hash
        # tweet_geo = tweet["coordinates"]
        # users_last_location[name_freeze] = tweet_geo if (tweet_geo != "null")
        
        ## Set time of tweet to variable tweet_t
        time_arr = (tweet["created_at"].to_s.split(" "))
        time_time = (time_arr[3].to_s.split(":"))
        time_arr.delete_at(3)
        time_arr.insert(3, time_time[0].to_i, time_time[1].to_i, time_time[2].to_i)
        tweet_t = Time.new(time_arr[7].to_i,Date::ABBR_MONTHNAMES.index(time_arr[1]),time_arr[2].to_i,time_arr[3],time_arr[4],time_arr[5])

        if ($users_score[name].to_i == 0 || $users_score[name] == "") || (tweet_t > ($users_last_time[name] + (60 * 20)) && tweet_t < ($users_last_time[name] + (60 * 35)))
         
            if tweet_t == nil || (tweet_t < ($t_end - 160) && ($users_score[name].to_i) == 0)
                $tweetout << "@#{name} Start the quest at #{barnames[1]} - # 1"
                $users_score[name_freeze] = 1
                $users_last_time[name_freeze] = Time.new
            end
            ########
            # puts $tweetout[0]
            #########
        ## puts tweet["user"]["screen_name"] + " - " + tweet["text"]
        ## ^ Removed because list of tweets is flooding heroku logs
        # CHECK TWEET FOR KEY WORDS
        if keywords.all?{|keyword| tweet["text"].to_s.downcase.include? keyword}
        # If Key word found in tweet
        puts "Key words found in " + tweet["user"]["screen_name"] + " - " + tweet["text"]
        
        ## Check if Media is included in tweet
        ## If no pics, tweet "Pics or it didn't happen!"
        pic = (tweet["entities"].has_key?("media"))
        $tweetout << "@#{name} No dice! Pics or it didn't happen!" if (pic == false)
        
        ## SPLIT TWEET UP INTO WORDS 
        words = tweet["text"].to_s.split(" ")
        ## SEARCH FOR INTERGERS & GENERATE
        ## RANDOM +/- 1 ROLLS
        words.each do |word|
            if word.to_i < 5 && word.to_i != 0 && rollcount == 0 && pic
            botroll = - 1 + rand(3)
            roll = (word.to_i + botroll)
            botroll_talk = case botroll
                when -1 then ", but Pubquestbot takes 1 off you! "
                when 1 then ", but Pubquestbot gives you +1! "
                else ". "
            end
            go_to_bar = bars[[($users_score[name] + roll), 30].min]
            go_to_barname = barnames[go_to_bar]
            go_to_bartalk = barsnls[($users_score[name] + roll)]

            $tweetout << "@#{name} You're on #{$users_score[name]} and drank #{word.to_i}#{botroll_talk}You roll #{roll} to ##{($users_score[name] + roll)} - #{go_to_bartalk}#{go_to_barname} - # #{go_to_bar}"
            $users_score[name_freeze] = go_to_bar.to_i
            users_last_time[name_freeze] = tweet_t
            rollcount += 1
            
            else if word.to_i != 0 && rollcount == 0 && pic
            
            botroll = - 1 + rand(2)
            roll = (word.to_i + botroll)
            botroll_talk = case botroll
                when -1 then ", and Pubquestbot takes 1! "
                when 1 then " Pubquestbot gives you +1! "
                else ". "
            end
            go_to_bar = bars[[($users_score[name] + roll), 30].min]
            go_to_barname = barnames[go_to_bar]
            go_to_bartalk = barsnls[($users_score[name] + roll)]
            $tweetout << "@#{name} Drink count is maxed at 4#{botroll_talk}Your roll is #{roll} to ##{($users_score[name] + roll)} - #{go_to_bartalk}#{go_to_barname} - # #{go_to_bar}"
            
            $users_score[name_freeze] = go_to_bar.to_i
            users_last_time[name_freeze] = tweet_t
            rollcount += 1
            
            # end of else if word.to_i != 0
            end
            #end of word.to_i < 5
            end
        # end of words.each
        end
        
             # end of if keywords.all?{|str|...
            end

## TWEET BACK THE TWEETOUT
            thirdpath    = "/1.1/statuses/update.json"
            thirdaddress = URI("#{baseurl}#{thirdpath}")
            request = Net::HTTP::Post.new thirdaddress.request_uri
            request.set_form_data(
              "status" => "#{$tweetout[0]}",
            )
            
            # Set up HTTP.
            http             = Net::HTTP.new thirdaddress.host, thirdaddress.port
            http.use_ssl     = true
            http.verify_mode = OpenSSL::SSL::VERIFY_PEER
            
            # Issue the request.
            request.oauth! http, consumer_key, access_token
            http.start
            response = http.request request
            
            # Parse and print the Tweet if the response code was 200
            tweet = nil
            if response.code == '200' then
              tweet = JSON.parse(response.body)
              puts "Successfully sent #{tweet["text"]}"
            else
              puts "Could not send the Tweet! " +
              "Code:#{response.code} Body:#{response.body}"
            end
        
        puts $tweetout[0]
        puts "Users_score: " + name + " = " + $users_score[name].to_s
                
            # end of if tweet_t < users_last_time[name] && tweet_t < t
            end
            
            # end of tweets.reverse_each
            end
            
        ## sleep for 3 seconds, so don't get 429 code
           ############################
           sleep 2
           ############################
            
        # end of if response.code == '200'
        end

        #end of users.list.each
        end

    # end of def initialize()
    end

# end of class TwitterTweet 
end

include Clockwork

every(2.minutes, 'Queueing instruction-tweets') { Delayed::Job.enqueue TwitterDM.new }
every(2.minutes, 'Queueing twitter-tweet') { Delayed::Job.enqueue TwitterTweet.new }
