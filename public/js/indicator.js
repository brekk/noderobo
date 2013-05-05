(function() {
  var Indicator, MultiLight, Poller, events, five, manager, request, util, _;

  five = require('johnny-five');

  _ = require('lodash/dist/lodash.underscore');

  request = require('request');

  manager = require('./manager');

  util = require('util');

  events = require('events');

  Poller = function(options) {
    var self;

    self = this;
    self._timer = null;
    self._poll = function() {};
    self._defaultParse = function(json) {
      var status;

      status = 'unknown';
      if (json.building) {
        status = 'building';
      } else if (json.result) {
        status = json.result.toLowerCase();
      }
      return status;
    };
    self._fetch = function(url, cb) {
      request(url, function(err, res, body) {
        var jBody, status;

        if (err) {
          throw err;
        }
        jBody = JSON.parse(body);
        return status = self.parse(jBody);
      });
      self.emit('response', status, jBody);
      if (status !== self.status) {
        self.status = status;
        return self.emit('change', status, jBody);
      }
    };
    self.start = function() {
      var next, url;

      url = self.options.url;
      interval(self.options.interval);
      next = function() {
        return self._timer = setTimeout(function() {
          return self._fetch(url, next);
        }, interval);
      };
      self._fetch(url, next);
    };
    self.stop = function() {
      return clearTimeout(self._timer);
    };
    self._setup = function(opts) {
      var settings;

      settings = _.extend({
        parse: self._defaultParse,
        interval: 5000,
        url: ""
      }, opts);
      if (_.isString(settings.url) && settings.url === '') {
        throw new Error("Expected polling url.");
      }
      self.options = settings;
      self.parse = settings.parse;
      return manager.setup(self, Poller);
    };
    return self._setup(options);
  };

  util.inherits(Poller, events.EventEmitter);

  MultiLight = function(options) {
    var self;

    self = this;
    self._colors = ['red', 'green', 'blue'];
    self._color = null;
    self._defaultSettings = {
      pins: {
        red: 10,
        green: 11,
        blue: 9
      },
      "default": 'blue',
      colors: {
        success: 'green',
        failure: 'red',
        thinking: 'blue'
      },
      aliases: {}
    };
    self.getColor = function() {
      return self._color;
    };
    self._setColor = function(value) {
      var current, others;

      if (_(self._colors).contains(value)) {
        self._color = value;
        current = self[self_color];
        if (!current.isOn) {
          current.fadeIn();
        }
        others = _(self._colors).without(self._color);
        return _(others).each(function(led) {
          led.fadeOut();
        });
      } else {
        throw new Error("No color with value " + value);
      }
    };
    self.think = function() {
      return self._setColor(self._settings.colors.thinking);
    };
    self.success = function() {
      return self._setColor(self._settings.colors.success);
    };
    self.failure = function() {
      return self._setColor(self._settings.colors.failure);
    };
    self.deactivate = function() {
      return _(self._colors).every(function(color) {
        self[color].deactivate();
        return true;
      });
    };
    self.activate = function() {
      return _(self._colors).every(function(color) {
        console.log(_(self[color]).methods(), "<>");
        return true;
      });
    };
    self._setup = function(opts) {
      var keyAliases;

      if (opts == null) {
        opts = {};
      }
      console.log("setting up MultiLight");
      self._settings = _.extend(self._defaultSettings, opts);
      _(self._colors).each(function(color) {
        console.log(color, '<----', self._settings.pins[color]);
        self[color] = new five.Led(self._settings.pins[color]);
      });
      console.log(_(self).keys(), 'yeskeys');
      keyAliases = _(self._settings.aliases).keys();
      _(keyAliases).each(function(key) {
        var alias;

        alias = self._settings.aliases[key];
        if (_.isFunction(self[key])) {
          self[alias] = self[key];
        }
      });
      console.log("SMIGGLE", self);
      return manager.setup(self, MultiLight);
    };
    return self._setup(options);
  };

  Indicator = function(config) {
    var self;

    self = this;
    self._multilight = null;
    self._poller = null;
    self._setupBoard = function(settings) {
      console.log("SETTING THE BOARD UP");
      self._board = new five.Board();
      console.log("board set:", !!self._board);
      self._board.on('ready', function() {
        var e, instructions, multilight;

        try {
          console.log("BOARD READY");
          multilight = new MultiLight(settings.light);
          console.log("MULTI", multilight);
          self._multilight = multilight;
          self._board.repl.inject({
            multilight: multilight
          });
          console.log("yer mom", self._multilight);
          instructions = _(settings.instructions).keys();
          console.log("structos", instructions);
          if (instructions.length > 0) {
            console.log('instructions found!');
            _(instructions).each(function(key) {
              var instruction;

              console.log('key: ' + key);
              instruction = settings.instructions[key];
              if (_.isFunction(self[key])) {
                console.log("fuck tion()");
                return self[key](instruction);
              }
            });
          }
        } catch (_error) {
          e = _error;
          return console.log("Error during board ready event: ", e.message, e.stack);
        }
      });
    };
    self.getPoller = function() {
      return self._poller;
    };
    self.getLight = function() {
      return self._multilight;
    };
    self._lightShow = function() {
      console.log(_(self._multilight).keys(), "KEYS");
      console.log("turning all lights on!");
      self._multilight.activate();
      setTimeout(function() {
        console.log('failure!');
        return self._multilight.failure();
      }, 2000);
      setTimeout(function() {
        console.log('success');
        return self._multilight.success();
      }, 4000);
      setTimeout(function() {
        console.log('thinking');
        return self._multilight.thinking();
      }, 6000);
      return setTimeout(function() {
        console.log('off!');
        return self._multilight.deactivate();
      }, 8000);
    };
    self._setup = function(conf) {
      var e, settings;

      if (conf == null) {
        conf = null;
      }
      console.log("CREATING THE INDICATOR!", conf);
      try {
        settings = _.extend({
          instructions: {},
          light: {},
          poller: {}
        }, conf);
        self._setupBoard(settings);
        console.log("BOARD SET UP");
        return manager.setup(self);
      } catch (_error) {
        e = _error;
        return console.log("Error setting up Indicator.", e.message);
      }
    };
    return self._setup(config);
  };

  module.exports = {
    Indicator: Indicator,
    MultiLight: MultiLight
  };

}).call(this);
