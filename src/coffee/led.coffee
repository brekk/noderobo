five = require 'johnny-five'
board = new five.Board()
board.on 'ready', ()->
    led = new five.Led({pin: 13})
    led.on()
    led.off()
    @wait 3000, ()->
        led.on()