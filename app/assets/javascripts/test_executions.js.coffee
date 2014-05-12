do_on_load = ->
  console.log "Hello World"

$(document).ready(do_on_load)
$(window).bind('page:change', do_on_load)