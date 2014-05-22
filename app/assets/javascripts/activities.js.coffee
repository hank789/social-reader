class Activities
  constructor: ->
    Pager.init 50, true
    @go_to_top()
    $(".event_filter_link").bind "click", (event) =>
      event.preventDefault()
      @toggleFilter($(event.currentTarget))
      @reloadActivities()

  reloadActivities: ->
    $(".content_list").html ''
    Pager.init 50, true


  toggleFilter: (sender) ->
    sender.parent().toggleClass "inactive"
    event_filters = $.cookie("event_filter")
    filter = sender.attr("id").split("_")[0]
    if event_filters
      event_filters = event_filters.split(",")
    else
      event_filters = new Array()

    index = event_filters.indexOf(filter)
    if index is -1
      event_filters.push filter
    else
      event_filters.splice index, 1

    $.cookie "event_filter", event_filters.join(","), { path: '/' }

  go_to_top: ->
    # Go Top
    $("a.go_top").click () ->
      $('html, body').animate({ scrollTop: 0 },300)
      return false

    # Go top
    $(window).bind 'scroll resize', ->
      scroll_from_top = $(window).scrollTop()
      if scroll_from_top >= 1
        $("a.go_top").show()
      else
        $("a.go_top").hide()

@Activities = Activities
