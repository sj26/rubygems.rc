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

  #$(".documentation").on "click", ".source .title", (e) ->
  #  e.preventDefault()
  #  $code = $(e.target).parents(".source").find(".highlighttable")
  #  if $code.is ":hidden"
  #    $code.show()
  #    $(e.target).addClass("expanded")
  #  else
  #    $code.hide()
  #    $(e.target).removeClass("expanded")
