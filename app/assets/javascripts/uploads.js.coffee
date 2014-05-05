# uploads file
jQuery ->
  $('#upload_uploaded_file').attr('name','upload[uploaded_file]')
  $('#new_upload').fileupload
    dataType: 'script'
    add: (e, data) ->
      file = data.files[0]
      data.context = $(tmpl("template-upload", file))
      $('#new_upload').append(data.context)
      $('.actions input[type="submit"]').click (e) ->
        data.submit()
        e.preventDefault()
    progress: (e, data) ->
      if data.context
        progress = parseInt(data.loaded / data.total * 100, 10)
        data.context.find('.bar').css('width', progress + '%')
    done: (e, data) ->
      $('.actions input[type="submit"]').off('click')
