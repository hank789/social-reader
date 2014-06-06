class Activities
  constructor: ->
    Pager.init 50, true
    @go_to_top()
    $(".event_filter_link").bind "click", (event) =>
      event.preventDefault()
      @toggleFilter($(event.currentTarget))
      @reloadActivities()
    $(".event_star_filter_link").bind "click", (event) =>
      event.preventDefault()
      @toggleStarFilter($(event.currentTarget))
      @reloadActivities()
    $(".event_service_filter_link").bind "click", (event) =>
      event.preventDefault()
      @toggleServiceFilter($(event.currentTarget))
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

  toggleStarFilter: (sender) ->
    event_filters = $.cookie("event_star_filter")
    filter = sender.attr("id").split("_")[0]
    if event_filters
      event_filters = event_filters.split(",")
    else
      event_filters = new Array()

    index = event_filters.indexOf(filter)
    filter_s= if filter == "posttime" then "startime" else "posttime"
    index_s = event_filters.indexOf(filter_s)
    $("#"+filter_s+"_event_filter").parent().addClass "inactive"
    sender.parent().removeClass "inactive"
    if index is -1
      event_filters.push filter
      if index_s >= 0
        event_filters.splice index_s, 1
    else
      if index_s >= 0
        event_filters.splice index_s, 1
    $.cookie "event_star_filter", event_filters.join(","), { path: '/' }

  toggleServiceFilter: (sender) ->
    filter = sender.attr("id").split("_")[0]
    event_filters_origin = $.cookie("event_filter")
    if event_filters_origin
      event_filters_origin = event_filters_origin.split(",")
    else
      event_filters_origin = new Array()
    event_filters = new Array()
    event_filters.push filter
    for item in event_filters_origin
      $("#"+item+"_event_filter").parent().addClass "inactive"
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
