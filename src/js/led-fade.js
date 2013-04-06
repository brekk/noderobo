(function() {
  var board, five;

  five = require('johnny-five');

  board = new five.Board();

  board.on('ready', function() {
    var led;

    led = new five.Led(13);
    led.strobe(100);
  });

}).call(this);
