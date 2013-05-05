window.indicatorInit = ()->
    $ = window.jQuery
    ClientIndicator = ()->
        self = @
        self._socket = null
        self.listen = (socket)->
            self._socket = socket
            self.broadcast = (event, obj)->
                self._socket.emit event, obj
            self._socket.on 'status:change', (msg)->
                console.log msg
                {status, body} = msg
                $('.active').fadeOut()
                $("#"+status).fadeIn().addClass('active').find('h1').text body
        return self
    indicator = window.indicator = new ClientIndicator()
    $(document).ready ()->
        $('#loading').fadeOut()
        $('.hidden').removeClass('hidden').hide()
        indicator.listen(io.connect('http://localhost'))
