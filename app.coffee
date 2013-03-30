_ = require 'underscore'
express = require 'express.io'
uncapitalize = require('express-uncapitalize')
partials = require('express-partials')

app = express().http().io()

app.configure ()->
    console.log("Microcontroller")
    app.set "env", "development"
    app.set "views", "views"
    app.set "view engine", "coffeecup"
    app.engine 'coffee', require('coffeecup').__express
    app.use uncapitalize()
    app.use express.static(__dirname + '/public')
    app.use express.logger({ format: ':method :url :status in :response-time sms' })
    app.use express.cookieParser()
    app.use partials()
    app.use express.bodyParser()
    app.use express.methodOverride()
    app.use express.json()
    app.use express.urlencoded()
    app.use express.session({
      secret: "config.constants.SECRET"
      key: "config.constants.KEY"
    })
    app.use app.router
    app.use (err, req, res, next)->
        if err
            console.log err.stack, "stacks on deck"
            res.send 500, 'SOMETHING BROKE'

app.get '/', (req, res)->
    res.send "MICROCONTROLLER!"

app.listen('6969')
