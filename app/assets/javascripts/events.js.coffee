@Events =
  favorite: (el) ->
    event_id = $(el).data("id")
    if $("i", el).hasClass("icon-star")
      $.ajax
        url: "/events/#{event_id}/unfavorite"
        type: "POST"
      $("i", el).attr("class", "icon-star-empty")
    else
      $.ajax
        url: "/events/#{event_id}/favorite"
        type: "POST"
      $("i", el).attr("class", "icon-star")
    false
