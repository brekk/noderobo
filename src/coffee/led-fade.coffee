five = require 'johnny-five'
board = new five.Board()
board.on 'ready', ()->
    led = new five.Led 13
    led.strobe 100
    return

