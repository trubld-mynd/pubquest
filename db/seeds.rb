# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'rubygems'
require 'oauth'
require 'json'
require 'time'
require 'date'

$oldnames = ["PoisonSlammers", "TheWindSlayers", "PurpleSquirels", "TheGhostSharks", "MightyCommandos", "DreamLightning", "StokedTurtles"]
$oldusers_list = Hash[$oldnames.map{|user| [user, 0]}]
$oldusers_score = Hash[$oldnames.map{|user| [user, 0]}]
$oldusers_pic = Hash[$oldnames.map{|user| [user, nil]}]

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
firstlocationquery = URI.encode_www_form(
    "screen_name" => "pubquestbot",
    "count" => 20,
    )
firstaddress = URI("#{baseurl}#{firstpath}?#{firstlocationquery}")
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

## FOR TESTING ON CADEACADEMY
            ## puts "$oldusers_list = " + $oldusers_list.to_s
            ## puts "$oldusers_score =" + $oldusers_score.to_s

## Get User current pic url from user's last tweet 

$oldnames.each do |oldname|
## FOR TESTING ON CADEACADEMY
            ## puts oldname
    secondpath = "/1.1/users/show.json?screen_name="
    secondquery = oldname.to_s
    secondaddress = URI("#{baseurl}#{secondpath}#{secondquery}")
    request = Net::HTTP::Get.new secondaddress.request_uri

    http             = Net::HTTP.new secondaddress.host, secondaddress.port
    http.use_ssl     = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    request.oauth! http, consumer_key, access_token
    http.start
    response = http.request request

    usertweet = nil
        if response.code == '200' then
          usertweet = JSON.parse(response.body)
            ## FOR TESTING ON CADEACADEMY
            ## puts usertweet["name"].to_s
            ## puts usertweet["profile_image_url"].to_s
            user_proper_name = usertweet["name"]
            user_pic = usertweet["profile_image_url"]
            user_name_freeze = oldname.freeze
            if user_pic != nil && user_pic != ""
                ## LOAD USER PIC to users_pic HASH
                $oldusers_list[user_name_freeze] = user_proper_name
                $oldusers_pic[user_name_freeze] = user_pic
        # if to_user != nil
        end
    # end of response.code == '200'
    end

oldname = User.create(name: $oldusers_list[oldname], name_profile_image_url: $oldusers_pic[oldname], score: $oldusers_score[oldname])

# end of $oldusers_list.each
end

## FOR TESTING ON CODE ACADEMY 
## puts "$oldusers_pic = " + $oldusers_pic.to_s