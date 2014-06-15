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

  share_to_global_chat: (el) ->
    post_id = $(el).data("id")

    $.ajax
      url: "/notes"
      type: "POST"
      data:
        post_id : post_id
        chat_type : "GlobalChat"
        note: "just a test"
      success: (msg) ->
        $(el).hide()
        $('.dash-sidebar-tabs #sidebar-gloablchat-tab').click()

    false
