$ ->
  if (title = $("#generating-docs")).length
    queuePoll = ->
      setTimeout ->
        $.ajax
          url: title.data("status_url")
        .done (status) ->
          if status == "ready"
            document.location.reload()
          else if status == "error"
            $("#loading").hide()
            $("#fail").show()
          else
            queuePoll()
        .fail (xhr) ->
          $("#loading").hide()
          $("#fail").show()
      , 2000
    queuePoll()
