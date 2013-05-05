five = require('johnny-five')
_ = require('lodash/dist/lodash.underscore')
request = require('request')
manager = require('./manager')
util = require 'util'
events = require 'events'

Poller = (options)->
    self = @
    self._timer = null
    self._poll = ()->
    self._defaultParse = (json)->
        status = 'unknown'
        if json.building
            status = 'building'
        else if json.result
            status = json.result.toLowerCase()
        return status
    self._fetch = (url, cb)->
        request url, (err, res, body)->
            if err
                throw err
            jBody = JSON.parse(body)
            status = self.parse(jBody)
        self.emit 'response', status, jBody
        if status != self.status
            self.status = status
            self.emit 'change', status, jBody
    
    self.start = ()->
        url = self.options.url
        interval self.options.interval
        next = ()->
            self._timer = setTimeout ()->
                self._fetch url, next
            , interval
        self._fetch url, next
        return

    self.stop = ()->
        clearTimeout self._timer

    self._setup = (opts)->
        settings = _.extend {
            parse: self._defaultParse
            interval: 5000
            url: ""
        }, opts
        if _.isString(settings.url) and settings.url == ''
            throw new Error "Expected polling url."
        self.options = settings
        self.parse = settings.parse
        return manager.setup self, Poller
    return (self._setup)(options)

util.inherits Poller, events.EventEmitter

MultiLight = (options)->
    self = @
    self._colors = ['red', 'green', 'blue']
    self._color = null
    self._defaultSettings = {
        pins: {
            red: 10
            green: 11
            blue: 9
        }
        default: 'blue'
        colors: {
            success: 'green'
            failure: 'red'
            thinking: 'blue'
        }
        aliases: {} #setting a success property equal to a string makes that a functional alias
    }

    self.getColor = ()->
        return self._color

    self._setColor = (value)->
        if _(self._colors).contains value
            self._color = value
            current = self[self_color]
            if !current.isOn
                current.fadeIn()
            others = _(self._colors).without self._color
            _(others).each (led)->
                led.fadeOut()
                return
        else
            throw new Error "No color with value #{value}"

    self.think = ()->
        self._setColor self._settings.colors.thinking

    self.success = ()->
        self._setColor self._settings.colors.success

    self.failure = ()->
        self._setColor self._settings.colors.failure

    self.deactivate = ()->
        return _(self._colors).every (color)->
            self[color].deactivate()
            return true

    self.activate = ()->
        return _(self._colors).every (color)->
            console.log _(self[color]).methods(), "<>"
            # self[color].on()
            return true

    self._setup = (opts={})->
        console.log "setting up MultiLight"
        self._settings = _.extend self._defaultSettings, opts
        # convert colors from array to properties with pins
        _(self._colors).each (color)->
            console.log color, '<----', self._settings.pins[color]
            self[color] = new five.Led(self._settings.pins[color])
            return
        console.log _(self).keys(), 'yeskeys'
        keyAliases = _(self._settings.aliases).keys()
        _(keyAliases).each (key)->
            alias = self._settings.aliases[key]
            if _.isFunction self[key]
                self[alias] = self[key]
            return
        console.log "SMIGGLE", self
        return manager.setup self, MultiLight
    return (self._setup)(options)

Indicator = (config)->
    self = @
    self._multilight = null
    self._poller = null
    self._setupBoard = (settings)->
        console.log "SETTING THE BOARD UP"
        self._board = new five.Board()
        console.log "board set:", !!self._board
        self._board.on 'ready', ()->
            try
                console.log "BOARD READY"
                multilight = new MultiLight(settings.light)
                console.log "MULTI", multilight
                self._multilight = multilight
                self._board.repl.inject {multilight: multilight}
                console.log "yer mom", self._multilight
                # poller = new Poller(settings.poller)
                # console.log "yer poll", poller
                # poller.on 'change', (status, body)->
                #     console.log body.fullDisplayName, 'changed to', status
                #     if _.isFunction multilight[status]
                #         multilight[status]()
                #     else
                #         multilight.on()
                # poller.start()
                # self._poller = poller
                # console.log "SHIA SHIA", poller
                instructions = _(settings.instructions).keys()
                console.log "structos", instructions
                if instructions.length > 0
                    console.log 'instructions found!'
                    _(instructions).each (key)->
                        console.log 'key: '+key
                        instruction = settings.instructions[key]
                        if _.isFunction self[key]
                            console.log "fuck tion()"
                            self[key] instruction
                return
            catch e
                console.log "Error during board ready event: ", e.message, e.stack

        return

    self.getPoller = ()->
        return self._poller

    self.getLight = ()->
        return self._multilight

    self._lightShow = ()->
        console.log _(self._multilight).keys(), "KEYS"
        console.log "turning all lights on!"
        self._multilight.activate()
        setTimeout ()->
            console.log 'failure!'
            self._multilight.failure()
        , 2000
        setTimeout ()->
            console.log 'success'
            self._multilight.success()
        , 4000
        setTimeout ()->
            console.log 'thinking'
            self._multilight.thinking()
        , 6000
        setTimeout ()->
            console.log 'off!'
            self._multilight.deactivate()
        , 8000

    self._setup = (conf=null)->
        console.log "CREATING THE INDICATOR!", conf
        try
            settings = _.extend {
                instructions: {} #debug
                light: {}
                poller: {}
            }, conf
            self._setupBoard settings
            console.log "BOARD SET UP"
            return manager.setup self
        catch e
            console.log "Error setting up Indicator.", e.message
    return (self._setup)(config)

module.exports = {
    Indicator: Indicator
    MultiLight: MultiLight
}