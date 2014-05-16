ready = ->
    console.log "Ready Test Execution"
    console.log "reloading after 5s"
    setTimeout ( ->
      window.location.reload true
    ), 5000

$(document).ready(ready)
$(document).on('page:load', ready)