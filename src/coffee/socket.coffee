five = require 'johnny-five'
board = new five.Board()
io = require('socket.io').listen(5000)

io.sockets.on 'connection', (socket)->
    board.on 'on', ()->
        socket.emit 'on'

    board.on 'off', ()->
        socket.emit 'off'

    board.on 'hold', ()->
        socket.emit 'hold'

board.on 'ready', ()->
    led = new five.Led({pin: 13})
    button = new five.Button(8)
    board.repl.inject {
        button: button
    }

    button.on 'down', ()->
        led.on()
        board.emit 'on'
        console.log "down"
        return

    button.on 'hold', ()->
        board.emit 'hold'
        console.log 'hold'

    button.on 'up', ()->
        led.off()
        board.emit 'off'
        console.log 'up'
