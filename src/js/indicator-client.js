(function() {
  window.indicatorInit = function() {
    var $, ClientIndicator, indicator;

    $ = window.jQuery;
    ClientIndicator = function() {
      var self;

      self = this;
      self._socket = null;
      self.listen = function(socket) {
        self._socket = socket;
        self.broadcast = function(event, obj) {
          return self._socket.emit(event, obj);
        };
        return self._socket.on('status:change', function(msg) {
          var body, status;

          console.log(msg);
          status = msg.status, body = msg.body;
          $('.active').fadeOut();
          return $("#" + status).fadeIn().addClass('active').find('h1').text(body);
        });
      };
      return self;
    };
    indicator = window.indicator = new ClientIndicator();
    return $(document).ready(function() {
      $('#loading').fadeOut();
      $('.hidden').removeClass('hidden').hide();
      return indicator.listen(io.connect('http://localhost'));
    });
  };

}).call(this);
