five = require 'johnny-five'
board = new five.Board()
board.on 'ready', ()->
    led = new five.Led({pin: 13})
    button = new five.Button(8)
    board.repl.inject {
        button: button
    }

    button.on 'down', ()->
        led.on()
        console.log "down"
        return

    button.on 'hold', ()->
        console.log 'hold'

    button.on 'up', ()->
        led.off()
        console.log 'up'