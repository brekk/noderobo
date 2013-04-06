(function() {
  var board, five;

  five = require('johnny-five');

  board = new five.Board();

  board.on('ready', function() {
    var led;

    led = new five.Led({
      pin: 13
    });
    led.on();
    led.off();
    return this.wait(3000, function() {
      return led.on();
    });
  });

}).call(this);
