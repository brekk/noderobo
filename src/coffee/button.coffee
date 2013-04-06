five = require 'johnny-five'
board = new five.Board()
board.on 'ready', ()->
    button = new five.Button(8)
    board.repl.inject {
        button: button
    }

    button.on 'down', ()->
        console.log "down"

    button.on 'hold', ()->
        console.log 'hold'

    button.on 'up', ()->
        console.log 'up'