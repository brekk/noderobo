(function() {
  var board, five, io;

  five = require('johnny-five');

  board = new five.Board();

  io = require('socket.io').listen(5000);

  io.sockets.on('connection', function(socket) {
    board.on('on', function() {
      return socket.emit('on');
    });
    board.on('off', function() {
      return socket.emit('off');
    });
    return board.on('hold', function() {
      return socket.emit('hold');
    });
  });

  board.on('ready', function() {
    var button, led;

    led = new five.Led({
      pin: 13
    });
    button = new five.Button(8);
    board.repl.inject({
      button: button
    });
    button.on('down', function() {
      led.on();
      board.emit('on');
      console.log("down");
    });
    button.on('hold', function() {
      board.emit('hold');
      return console.log('hold');
    });
    return button.on('up', function() {
      led.off();
      board.emit('off');
      return console.log('up');
    });
  });

}).call(this);
