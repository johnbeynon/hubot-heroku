Heroku hubot script
======================

Work in progress!

This hubot script will let you control your heroku apps via hubot.

    hubot heroku ps --app <appname>

Will return the current processes in your application.

    hubot heroku ps:scale web=1 --app <appname>

Will scale your specified process

    hubot heroku ps:stop web --app <appname>

Will stop your specified process

    hubot heroku ps:restart web --app <appname>

Will restart the specified process.

## Installation

Easiest way is to copy src/heroku.coffee to your src/scripts folder in your
Hubot code.

Add a dependency on sprintf, to 0.1.1 in your packages.json file

    "sprintf": "0.1.1"
