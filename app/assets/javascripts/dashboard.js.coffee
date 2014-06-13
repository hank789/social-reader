class Dashboard
  constructor: ->
    @initSidebarTab()
    @initChatTab()

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
    $('.dash-sidebar-tabs a').on 'click', (e) ->
      $.cookie(key, $(e.target).attr('id'))

    $('#sidebar-clear-filter').on 'click', (e) ->
      $.cookie("event_filter", null)
      $(".content_list").html ''
      Pager.init 50, true

    # show tab from cookie
    sidebar_filter = $.cookie(key)
    $("#" + sidebar_filter).tab('show') if sidebar_filter

  initChatTab: ->
    new Wall(-1)

@Dashboard = Dashboard
