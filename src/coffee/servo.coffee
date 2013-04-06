five = require 'johnny-five'
board = new five.Board()
board.on 'ready', ()->
    servo = new five.Servo {
        pin: 13
        # range: [0, 180]
        # startAt: 20
        # type: 'continuous'
    }
    board.repl.inject {
        servo: servo
    }
    # servo.move 110
    servo.sweep()
    servo.on 'move', (e, degrees)->
        console.log "move", degrees