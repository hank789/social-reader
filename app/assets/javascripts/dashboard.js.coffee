class Dashboard
  constructor: ->
    @initSidebarTab()
    $("#dashboard_sidebar").smartFloat()
    $(".dash-filter").keyup ->
      terms = $(this).val()
      uiBox = $(this).parents('.panel').first()
      if terms == "" || terms == undefined
        uiBox.find(".dash-list li").show()
      else
        uiBox.find(".dash-list li").each (index) ->
          name = $(this).find(".filter-title").text()

          if name.toLowerCase().search(terms.toLowerCase()) == -1
            $(this).hide()
          else
            $(this).show()



  initSidebarTab: ->
    key = "dashboard_sidebar_filter"
    # store selection in cookie
    $('.dash-sidebar-tabs #sidebar-services-tab').on 'click', (e) ->
      $.cookie(key, $(e.target).attr('id'))

    $('.dash-sidebar-tabs #sidebar-gloablchat-tab').on 'click', (e) ->
      $.cookie(key, $(e.target).attr('id'))

      if $('ul.notes li').html()

      else
        new Wall(-1)

    $('#sidebar-clear-filter').on 'click', (e) ->
      $.cookie("event_filter", null)
      $(".content_list").html ''
      Pager.init 50, true

    # show tab from cookie
    sidebar_filter = $.cookie(key)
    $("#" + sidebar_filter).tab('show') if sidebar_filter

  $.fn.smartFloat = ->
    position = (element) ->
      top = element.position().top
      pos = element.css("position")
      $(window).scroll ->
        scrolls = $(this).scrollTop()
        if scrolls > top
          if window.XMLHttpRequest
            element.css
              position: "fixed"
              top: 0
              overflow: "auto"
              height: "100%"

          else
            element.css top: scrolls
        else
          element.css
            position: "absolute"
            top: top
            overflow: "visible"



    $(this).each ->
      position $(this)


@Dashboard = Dashboard
