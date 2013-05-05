(function() {
  "use strict";
  var Manager, _;

  _ = require('underscore');

  /**
  @class Manager
  @namespace gameland
  */


  Manager = function() {
    var manager, _filterKeys, _returnSecure;

    manager = this;
    /**
    Filters underscore-prefixed '_' functions and properties
    @method _filterKeys
    @private
    @param {object} ref
    @return {object} filtered references
    */

    _filterKeys = function(ref) {
      var blacklistFunctions, whitelistFunctions;

      if (ref == null) {
        ref = this;
      }
      whitelistFunctions = _.keys(ref).filter(function(f) {
        return f.substr(0, 1) !== '_';
      });
      blacklistFunctions = _.keys(ref).filter(function(f) {
        return f.substr(0, 1) === '_';
      });
      return {
        pick: whitelistFunctions,
        omit: blacklistFunctions
      };
    };
    /**
    Returns a non-revealing copy of a given object, using _filterKeys as a filter method
    @method _returnSecure
    @private
    @param {object} ref
    @return {object} non-revealing object
    */

    _returnSecure = function(ref) {
      var filters, listedKeys, nonRevealingObject, properties;

      if (ref == null) {
        ref = this;
      }
      filters = _filterKeys(ref);
      listedKeys = _(ref).pick(filters.pick);
      nonRevealingObject = {};
      properties = [];
      _(listedKeys).each(function(prop, key) {
        properties.push(prop);
        nonRevealingObject[key] = ref[key];
        return true;
      });
      return nonRevealingObject;
    };
    /**
    Runs on every instance of every class in lexicon.
    Keeps everything standardized.
    
    @method initialize
    @public
    @param {object} obj
    @param {function} Constructor
    @return {object} securedObject
    @deprecated
    */

    /**
    Runs on every instance of every class in lexicon.
    Keeps everything standardized.
    
    @method setup
    @public
    @param {object} obj
    @param {function} Constructor
    @return {object} securedObject
    */

    manager.initialize = manager.setup = function(obj, Constructor) {
      var e, secured;

      if (obj == null) {
        obj = void 0;
      }
      if (Constructor == null) {
        Constructor = void 0;
      }
      try {
        if (_.isUndefined(obj)) {
          throw new TypeError("Unable to initialize undefined.");
        }
        if (!_.isUndefined(Constructor) && _.isFunction(Constructor)) {
          if (obj instanceof Constructor === false) {
            obj = new Constructor();
          }
        }
        secured = _returnSecure(obj);
        return secured;
      } catch (_error) {
        e = _error;
        console.log("INITIALIZING THIS FAILURE: \n\n", obj, "\n");
        console.warn("initialize() Error:", e.message);
        throw e;
      }
    };
    manager._init = function() {
      return _returnSecure(manager);
    };
    return manager._init();
  };

  module.exports = new Manager();

}).call(this);
