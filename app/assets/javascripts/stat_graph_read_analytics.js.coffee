class window.ReadAnalyticsStatGraph
  init: (log) ->
    if $("#read-analytics").length
      Morris.Area
        element: "read-analytics"
        data: JSON.parse(log)
        xkey: "period"
        ykeys: [
          "book"
          "read"
          "star"
        ]
        labels: [
          "Book"
          "Read"
          "Star"
        ]
        pointSize: 2
        hideHover: "auto"

    @change_date_header()
    return
  change_date_header: ->
    print = 'Analytics Example'
    $("#date_header").text(print)