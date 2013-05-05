"use strict"
_ = require('underscore')


###*
@class Manager
@namespace gameland
###
Manager = ()->
    manager = @
    ###*
    Filters underscore-prefixed '_' functions and properties
    @method _filterKeys
    @private
    @param {object} ref
    @return {object} filtered references
    ###
    _filterKeys =  (ref = this) ->
        whitelistFunctions = _.keys(ref).filter (f)->
                                return f.substr(0, 1) != '_'
        blacklistFunctions = _.keys(ref).filter (f)->
                                return f.substr(0, 1) == '_'
        # console.log blacklistFunctions, "blacklist", whitelistFunctions, "whitelist"
        return {pick: whitelistFunctions, omit: blacklistFunctions}

    ###*
    Returns a non-revealing copy of a given object, using _filterKeys as a filter method
    @method _returnSecure
    @private
    @param {object} ref
    @return {object} non-revealing object
    ###
    _returnSecure = (ref = this) ->
        filters = _filterKeys(ref)
        listedKeys = _(ref).pick(filters.pick)
        nonRevealingObject = {}
        properties = []
        _(listedKeys).each (prop, key)->
            properties.push prop
            nonRevealingObject[key] = ref[key]
            return true
        return nonRevealingObject

    ###*
    Runs on every instance of every class in lexicon.
    Keeps everything standardized.

    @method initialize
    @public
    @param {object} obj
    @param {function} Constructor
    @return {object} securedObject
    @deprecated
    ###
    ###*
    Runs on every instance of every class in lexicon.
    Keeps everything standardized.

    @method setup
    @public
    @param {object} obj
    @param {function} Constructor
    @return {object} securedObject
    ###
    manager.initialize = manager.setup = (obj = undefined, Constructor = undefined) ->
        # console.log obj, Constructor, "<-- initializing!"
        try
            if _.isUndefined obj
                throw new TypeError "Unable to initialize undefined."

            if !_.isUndefined(Constructor) and _.isFunction(Constructor)
                if obj instanceof Constructor == false
                    obj = new Constructor()

            secured = _returnSecure(obj)
            return secured
        catch e
            console.log "INITIALIZING THIS FAILURE: \n\n", obj, "\n"
            console.warn "initialize() Error:", e.message
            throw e

    manager._init = ()->
        return _returnSecure(manager)

    return (manager._init)()

# maker = ()->
#     return new Manager()
# singleton = _.once maker

module.exports = new Manager()