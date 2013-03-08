# A limited way to interact with the Heroku API.
#
# INSTALLATION:
# 1. Create file in scripts folder in hubot folder
# 2. Update package.json for hubot and add dependency on "sprintf": "0.1.1"
# 3. Set heroku config variable HEROKU_USER to heroku user account to use
# 4. Set heroku config variable HEROKU_APIKEY to heroku user account apikey (from My Account page)
#
# heroku status - Retrieve the most recent tweet from the @herokustatus account
# heroku ps --app <appname> - Get process information for application
# heroku ps:scale <process>=<quantity> --app <appname> - Scale the process to quantity for application
# heroku ps:restart <process> --app <appname> - Restart the specified process for application# 
# heroku ps:stop <process> --app <appname> - Stop the specified process for application
#
sprintf  = require("sprintf").sprintf

user = process.env.HEROKU_USER
apiKey = process.env.HEROKU_APIKEY

module.exports = (robot) ->
  # heroku ps --app <appname> - returns process information of heroku app
  robot.hear /heroku ps --app (.*)/i, (msg) ->
    application = msg.match[1]  
    uri = 'https://api.heroku.com/apps/' + application + '/ps'
    # get(uri)
    msg.http(uri)
      .headers(Authorization: "Basic #{new Buffer("#{user}:#{apiKey}").toString("base64")}", Accept: "application/json")
      .get() (err, res, body) ->
        if res.statusCode is 404
          msg.send "Application not found"
          return

        results = JSON.parse(body)

        if res.statusCode is 403
          msg.send results.error
          return

        output = ""
        output += "Process       State               Command\n"
        output += "------------  ------------------  ------------------------------\n"

        for process in results
          output += sprintf("%-12s  %-18s  %-s", process.process, process.pretty_state, process.command) + "\n"
        msg.send output

  # heroku ps:scale <process>=<count> --app <appname>
  robot.respond /heroku ps:scale (.*)=(\d+) --app (.*)/i, (msg) ->
    type = msg.match[1]
    qty =  msg.match[2]
    application = msg.match[3]
    uri = 'https://api.heroku.com/apps/' + application + '/ps/scale'
    msg.http(uri)
    .headers(Authorization: "Basic #{new Buffer("#{user}:#{apiKey}").toString("base64")}", Accept: "application/json", 'Content-Length': 0)
    .query(type: type, qty: qty)
    .post() (err, res, body) ->
      if res.statusCode is 404
        msg.send "Application not found"
        return
  
      if res.statusCode is 403
        msg.send JSON.parse(body).error
        return

      msg.send "Now running: " + body

  # heroku ps:restart <process> --app <appname>
  robot.respond /heroku ps:restart (.*) --app (.*)/i, (msg) ->
    type = msg.match[1]
    application = msg.match[2]
    uri = 'https://api.heroku.com/apps/' + application + '/ps/restart'
    msg.http(uri)
    .headers(Authorization: "Basic #{new Buffer("#{user}:#{apiKey}").toString("base64")}", Accept: "application/json", 'Content-Length': 0)
    .query(type: type)
    .post() (err, res, body) ->
      if res.statusCode is 404
        msg.send "Application not found"
        return

      if res.statusCode is 403
        msg.send JSON.parse(body).error
        return

      msg.send "Restarted " + type + " processes"

  # heroku ps:stop <process> --app <appname>
  robot.respond /heroku ps:stop (.*) --app (.*)/i, (msg) ->
    type = msg.match[1]
    application = msg.match[2]
    uri = 'https://api.heroku.com/apps/' + application + '/ps/stop'
    msg.http(uri)
    .headers(Authorization: "Basic #{new Buffer("#{user}:#{apiKey}").toString("base64")}", Accept: "application/json", 'Content-Length': 0)
    .query(type: type)
    .post() (err, res, body) ->
      if res.statusCode is 404
        msg.send "Application not found"
        return

      if res.statusCode is 403
        msg.send JSON.parse(body).error
        return

      msg.send "Stopped " + type + " processes"

  # heroku status
  robot.respond /heroku status/, (msg) ->
   msg.http("http://api.twitter.com/1/statuses/user_timeline/herokustatus.json?count=1")
    .get() (err, res, body) ->
      response = JSON.parse body
      if response[0]
       msg.send "#{response[0]['created_at']} > #{response[0]['text']}"
      else
       msg.send "Error"

