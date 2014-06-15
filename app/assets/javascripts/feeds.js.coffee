class Feeds
  constructor: ->
    $('.build-new-feed').bind "click", ->
      field = $('#feed_url')
      this.disabled = true
      slug = field.val()
      path = field.attr('data-feed-path')
      group = field.attr('data-feed-group')
      if(slug.length > 0)
        $.ajax
          type: "POST"
          url: path
          data:
            feed_url : slug
            feed_group : group
          success: (msg) ->
            window.location.reload(true)
      else
        this.disabled = false

    $('.rssfeeds-delete-feed').bind "click", ->
      field = $('#' + this.id)

      field_div = $('#radio-' + this.id)
      path = field.attr('data-feed-path')
      if(path)
        $.ajax
          type: "POST"
          url: path
          success: (msg) ->
            if msg == "1"
              field_div.hide()

@Feeds = Feeds
