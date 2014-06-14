$ ->
  new Dispatcher()

class Dispatcher
  constructor: () ->
    @initSearch()
    @initHighlight()
    @initPageScripts()

  initPageScripts: ->
    page = $('body').attr('data-page')

    unless page
      return false

    path = page.split(':')
    switch page
      when 'dashboard:stars', 'services:show'
        new Activities()
      when 'dashboard:show', 'dashboard:archive'
        new Dashboard()
        new Activities()
      when 'rssfeeds:add_rss_feed', 'rssfeeds:rss'
        new Feeds()


    switch path.first()
      when 'admin' then new Admin()


  initSearch: ->
    opts = $('.search-autocomplete-opts')
    path = opts.data('autocomplete-path')
    project_id = opts.data('autocomplete-project-id')
    project_ref = opts.data('autocomplete-project-ref')

    new SearchAutocomplete(path, project_id, project_ref)

  initHighlight: ->
    $('.highlight pre code').each (i, e) ->
      $(e).html($.map($(e).html().split("\n"), (line, i) ->
        "<span class='line' id='LC" + (i + 1) + "'>" + line + "</span>"
      ).join("\n"))
      hljs.highlightBlock(e)
