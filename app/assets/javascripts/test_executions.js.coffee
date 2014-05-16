do_on_load = ->
    console.log "Hello World"

$(document).ready(do_on_load)
$(document).on('page:load', do_on_load)