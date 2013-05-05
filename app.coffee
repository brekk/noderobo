_ = require 'underscore'
express = require 'express.io'
uncapitalize = require('express-uncapitalize')
partials = require('express-partials')
Indicator = require('./src/js/indicator')

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

app.get '/button', (req, res)->
    res.send 'finish the button linkage, bro'

indicator = null

app.get '/indicator', (req, res)->
    debugParse = (r)->
        opts = ['success', 'failure', 'thinking']
        return opts[Math.floor(Math.random()*opts.length)]
    indicatorSettings = {
        poller: {
            parse: debugParse
            url: 'http://localhost'
        }
    }
    req.session.boards = {}
    indicator = new Indicator indicatorSettings
    req.session.indicator = indicator
    res.render 'indicator', {layout: false}, (err, html)->
        if err
            console.log "Error setting up Indicator"
        res.send html

app.io.route 'board', (req)->
    _(req.session.boards).each (board)->
        req.io.join board.uid()
        return

app.io.route 'connection', (req)->
    poller = indicator.getPoller()
    if !_.isNull poller
        poller.once 'response', (status, board)->
            req.io.emit 'status:change', {status: poller, body: body}

app.io.route 'change', (req)->
    poller = indicator.getPoller()
    if !_.isNull poller
        req.io.emit 'status:change', {status: status, body: body}



app.listen(4800)
