# Description:
#   Allows Hubot to control Heroku applications
#
# Dependencies:
#   "sprintf": "0.1.1"
#
# Configuration:
#   HUBOT_HEROKU_USER
#   HUBOT_HEROKU_APIKEY
#
# Commands:
#   heroku ps --app <appname> - Get process information for application
#   heroku ps:scale <process>=<quantity> --app <appname> - Scale the process to quantity for application
#   heroku ps:restart <process> --app <appname> - Restart the specified process for application# 
#   heroku ps:stop <process> --app <appname> - Stop the specified process for application
#
# Author:
#   John Beynon

sprintf  = require("sprintf").sprintf

user = process.env.HUBOT_HEROKU_USER
apiKey = process.env.HUBOT_HEROKU_APIKEY

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

