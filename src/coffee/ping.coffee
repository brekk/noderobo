five = require 'johnny-five'
board = new five.Board()
board.on 'ready', ()->
    ping = new five.Ping(13)

    ping.on 'read', (err, value)->
        console.log 'read', value

    ping.on 'change', (err, value)->
        console.log typeof this.inches
        console.log "Object is #{@.inches} inches away."

