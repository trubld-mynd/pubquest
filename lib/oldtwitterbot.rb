require 'rubygems'
require 'oauth'
require 'json'
require 'time'
require 'date'

require 'clockwork'
require './config/boot'
require './config/environment'

$t_start = Time.new(2014,9,12,17,30,0,"+10:00")
$t_start_local = $t_start.localtime("+10:00") 
$t_end = Time.new(2014,9,12,20,00,0,"+10:00")
$t_end_local = $t_end.localtime("+10:00") 
$startmessages = ["Hi there...",
    "Welcome to Snakes N Ladders Pub Quest! I am the Pub Questbot. Tweet me your drink count at each pub (max 4) AND A PHOTO", 
       "E.g. if your team has had 3 drinks, take a photo of your team with the drinks, and tweet '@pubquestbot 3 drinks'. Don't forget the pic!",
       "Your move will be determined by your 'dice roll' (your drink count +/-1). E.g. your 3 drinks might move you 2, 3 or 4 spaces on the board.",
       "I will then tell you where to go (If you land on a snake/ladder, I'll send you straight to the bottom/top of it).",
       "I'm only awake every 20 mins. Make sure your tweet to me is the last thing you tweet to anyone before I wake, or I'll give you a roll of 1.",
       "Tweeting more than 4 drinks will land you a 1 point penalty - you'd get 2, 3 or 4 instead of 3, 4 or 5.",
       "The winner will be the first to roll on to Frankie's, OR the team that gets the furtherest in 2.5 hours.",
       "I will start the pubquest at#{$t_start_local.strftime(" %I:%M%p")} and finish at#{$t_end_local.strftime(" %I:%M%p")} local time.",
       "Check out the Snakes N Ladders map, and a copy of these rules, at the website http://www.pubquest.info",
        "LET THE GAMES BEGIN!",
        "The pubquest is over! Come to Frankie's Pizza (Pub 30) to celebrate & party with the winners!"]
$directmessages = Hash[$startmessages.map{|msg| [msg, 0]}]

$names = ["PoisonSlammers", "TheWindSlayers", "PurpleSquirels", "TheGhostSharks", "MightyCommandos", "DreamLightning", "StokedTurtles"]
$oldusers_list = Hash[$names.map{|user| [user, 0]}]
$oldusers_score = Hash[$names.map{|user| [user, 0]}]

class OldTwitterRead
    def initialize()

t = Time::new
t_local = t.localtime("+10:00")
t_local_string = t_local.strftime(" %I:%M%p")

## Establish Users

## Verify connection to Twitter API
consumer_key = OAuth::Consumer.new(
"lZLYSIi4dbgIN9yRzTcIeP8Fk",
"3BqN9Qz9iVdYpPKJxXR0hjuaC1KXXPc03lIv02PyZGnXo5CRhR")
access_token = OAuth::Token.new(
"2776153651-zpSsnVPbMUhl34fWK2DdCmAhc2kG41aDPaZxiBP",
"yiXJmkrdheEi4PNGu4IS7WcX1tC9y9hDR06EFqOtIg2Gg")
baseurl = "https://api.twitter.com"

## Tweet that pubquest bot is awake
## and reading tweets
###################################

## Establish Keywords
keywords = ["pubquestbot", "drinks"]

## Establish Bar Locations

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
    ## puts bottweet["user"]["name"] + " - " + bottweet["text"]
    ## Identify User from bottweet
   to_user = bottweet["in_reply_to_screen_name"]
    to_user_freeze = to_user.freeze
    if to_user != nil && to_user != ""
        ## SPLIT TWEET UP INTO WORDS 
        botwords = bottweet["text"].to_s.split(" ")
        lastpub = botwords.last.to_i
        $oldusers_score[to_user_freeze] = lastpub
    # if to_user != nil
    end
    # end of bottweets.reverse_each
    end
# end of response.code == '200'
end

puts "users_score = " + $oldusers_score.to_s

    # end of def initialize()
    end

# end of class TwitterTweet 
end



include Clockwork
every(180.minutes, 'Queueing twitter-tweet') { Delayed::Job.enqueue OldTwitterRead.new }