(function() {
  var board, five;

  five = require('johnny-five');

  board = new five.Board();

  board.on('ready', function() {
    var servo;

    servo = new five.Servo({
      pin: 13
    });
    board.repl.inject({
      servo: servo
    });
    servo.sweep();
    return servo.on('move', function(e, degrees) {
      return console.log("move", degrees);
    });
  });

}).call(this);
