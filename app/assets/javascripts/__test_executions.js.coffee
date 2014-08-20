ready = ->
    console.log "CoffeeScript Ready Test Execution"

$(document).ready(ready)
$(document).on('page:load', ready)