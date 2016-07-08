require "net/https"
require "json"

# CONFIG - Initialise Variables
# API ClientID & Secret
cliID = '<ENTER YOUR CLIENT ID HERE>'
cliSec = '<ENTER YOUR CLIENT SECRET HERE>'
# Untappd Username
user = '<ENTER YOUR UNTAPPED USERNAME HERE>'

# Uncomment whichever size of Badge to display
#badgeimagesize = 'badge_image_sm'
badgeimagesize = 'badge_image_md'
#badgeimagesize = 'badge_image_lg'

#### API ADDRESS & CALLS #####
apibaseurl = 'https://api.untappd.com/v4/user/'
info = 'info'
badges = 'badges'

# Only send an update if we get a response from both queries
# This will prevent the history from only storing some of the values
send_update_1 = false
send_update_2 = false

SCHEDULER.every '5m', :first_in => 0 do |job|
        uri = URI.parse("#{apibaseurl}#{info}/#{user}?client_id=#{cliID}&client_secret=#{cliSec}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)

        if response.code == "200"
                result = JSON.parse(response.body)
                uniquebeers = result["response"]["user"]["stats"]["total_beers"]
                numbadges = result["response"]["user"]["stats"]["total_badges"]
                latestlabel = result["response"]["user"]["recent_brews"]["items"][0]["beer"]["beer_label"]
                latestname = result["response"]["user"]["recent_brews"]["items"][0]["beer"]["beer_name"]
                latestrating = result["response"]["user"]["recent_brews"]["items"][0]["beer"]["auth_rating"]
                latestbrewery = result["response"]["user"]["recent_brews"]["items"][0]["brewery"]["brewery_name"]
                avatar = result["response"]["user"]["user_avatar"]
                profile_url = result["response"]["user"]["untappd_url"]
                send_update_1 = true
        end

        uri = URI.parse("#{apibaseurl}#{badges}/#{user}?client_id=#{cliID}&client_secret=#{cliSec}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)

        if response.code == "200"
                result = JSON.parse(response.body)
                latestbadge = result["response"]["items"][7]["badge_name"]
                latestbadgeimage = result["response"]["items"][7]["media"]["#{badgeimagesize}"]
                send_update_2 = true
        end

        if send_update_1 && send_update_2
                send_event('untappd', { untappd_username: user, untappd_avatar: avatar, untappd_url: profile_url, untappd_uniquebeers: uniquebeers, untappd_badges: numbadges, untappd_latest_beer_label: latestlabel, untappd_latest_beer_name: latestname, untappd_latest_beer_myrating: latestrating, untappd_latest_beer_brewery: latestbrewery, untappd_latest_badge: latestbadge, untappd_latest_badge_image: latestbadgeimage })
        end
end
