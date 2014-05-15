do_on_load = ->
    console.log "Hello World"
    //poll_test_execution_status

$(document).ready(do_on_load)
$(document).bind('page:load', do_on_load)