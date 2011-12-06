#
# Automatically regularly (every minute) fetches the tweets on some search you've defined
# And sends them on the room
#
# Note : the bot will start looking only when someone says something in the room (at every restart, you have to
# say something in order to get the robot to fetch).
# When you've talked once though, it'll continue looking until it's restarted
#
# You can configure several terms with commas : evome,rails
#
# On heroku, configure the terms with config:add :
#
#    heroku config:add HUBOT_TWITTER_AUTO_SEARCH=evome,rails --app my-hubot-app

Twitter = {
  checkTweets: (msg) ->
    searches = process.env.HUBOT_TWITTER_AUTO_SEARCH || ''

    for search in searches.split(',')
      Twitter.checkTweet(search, msg)

  checkTweet: (search, msg) ->
    msg.http('http://search.twitter.com/search.json')
    .query(q: search)
    .get() (err, res, body) ->
      tweets = JSON.parse(body)
      if msg.robot.brain.data.auto_tweets == undefined
        msg.robot.brain.data.auto_tweets = {}

      last_displayed_tweet = msg.robot.brain.data.auto_tweets[search]

      if tweets.results? and tweets.results.length > 0
        tweets = tweets.results

        if last_displayed_tweet != undefined
          for tweet, i in tweets
            if tweet.id_str == last_displayed_tweet
              display_tweets = tweets.splice(0, i)
              break
        if display_tweets == undefined
          display_tweets = [tweets[0]]

        msg.robot.brain.data.auto_tweets[search] = tweets[0].id_str
        for tweet in display_tweets.reverse()
          msg.send "http://twitter.com/#!#{tweet.from_user}/status/#{tweet.id_str}"

  setTimeout: (msg, callback, force) ->
    if Twitter.timer == undefined or force == true
      Twitter.timer = setTimeout (->
        callback(msg)
        Twitter.setTimeout(msg, callback, true)
      ), 60*1000
}

module.exports = (robot) ->
  robot.hear //, (msg) ->

    Twitter.checkTweets(msg)
    Twitter.setTimeout msg, ->
      Twitter.checkTweets(msg)
