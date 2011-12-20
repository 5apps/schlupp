# Listens for Trajectory story links.
#
# paste a Trajectory story URL - sends back some story details
#
# You need to set the following variables:
#   HUBOT_TRAJECTORY_APIKEY: your Trajectory API key
#   HUBOT_TRAJECTORY_ACCOUNT: your Trajectory Account number
#   HUBOT_TRAJECTORY_PROJECT: the project ID
#
module.exports = (robot) ->
  robot.hear /apptrajectory\.com\/\w+\/\w+\/stories\/\d+/i, (msg) ->
    apiKey = process.env.HUBOT_TRAJECTORY_APIKEY
    account = process.env.HUBOT_TRAJECTORY_ACCOUNT
    project = process.env.HUBOT_TRAJECTORY_PROJECT

    unless apiKey && account && project
      msg.send "Please set HUBOT_TRAJECTORY_APIKEY, HUBOT_TRAJECTORY_ACCOUNT and HUBOT_TRAJECTORY_PROJECT appropriately"
      return

    storyId = msg.message.text.match(/\d+$/)
    storyURL = "https://www.apptrajectory.com/api/#{apiKey}/accounts/#{account}/projects/#{project}/stories/#{storyId}.json"

    msg.http(storyURL).get() (err, res, body) ->
      if err
        msg.send "Trajectory says: #{err}"
        return
      unless res.statusCode is 200
        msg.send "Got me a code #{res.statusCode}"
        return
      story = JSON.parse body
      message = "\"#{story.title}\""
      message += " (assigned to #{story.assignee_name})" if story.assignee_name
      message += " is a #{story.state} #{story.task_type}"
      msg.send message

