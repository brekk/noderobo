(function() {
  var board, five;

  five = require('johnny-five');

  board = new five.Board();

  board.on('ready', function() {
    var button;

    button = new five.Button(8);
    board.repl.inject({
      button: button
    });
    button.on('down', function() {
      console.log("down");
    });
    button.on('hold', function() {
      return console.log('hold');
    });
    return button.on('up', function() {
      return console.log('up');
    });
  });

}).call(this);
