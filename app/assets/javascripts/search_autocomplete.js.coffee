class SearchAutocomplete
  constructor: (search_autocomplete_path, post_id) ->
    post_id = '' unless post_id
    query = "?post_id=" + post_id

    $("#search").autocomplete
      source: search_autocomplete_path + query
      minLength: 1
      select: (event, ui) ->
        location.href = ui.item.url

@SearchAutocomplete = SearchAutocomplete
