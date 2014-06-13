class Wall
  constructor: (post_id) ->
    @post_id = post_id
    @note_ids = []
    @getContent()
    @initRefresh()
    @initForm()
  
  # 
  # Gets an initial set of notes.
  # 
  getContent: ->
    Api.notes @post_id, (notes) =>
      $.each notes, (i, note) =>
        # render note if it not present in loaded list
        # or skip if rendered
        if $.inArray(note.id, @note_ids) == -1
          @note_ids.push(note.id)
          @renderNote(note)
          @scrollDown()
          #$("abbr.timeago").timeago()

  initRefresh: ->
    setInterval =>
      @refresh()
    , 10000

  refresh: ->
    @getContent()

  scrollDown: ->
    notes = $('ul.notes')
    $('body, html').scrollTop(notes.height())

  initForm: ->
    form = $('.wall-note-form')
    form.find("#target_type").val('wall')

    form.on 'ajax:success', =>
      @refresh()
      form.find(".js-note-text").val("").trigger("input")
    
    form.on 'ajax:complete', ->
      form.find(".js-comment-button").removeAttr('disabled')
      form.find(".js-comment-button").removeClass('disabled')
    
    form.find('.note_text').keydown (e) ->
      if e.ctrlKey && e.keyCode == 13
        form.find('.js-comment-button').submit()

    form.show()
  
  renderNote: (note) ->
    if !note.user.avatar.url
      note.user.avatar.url = "https://secure.gravatar.com/avatar/668b2c160b3a956346859747446c7486?s=16&d=mm"
    template = @noteTemplate(note)
    $('ul.notes').append(template)

  noteTemplate: (note) ->
    html =
      """
      <li><span class="wall-author"><img src="#{note.user.avatar.url}" class="avatar s16" alt="">#{note.user.name}</span>
        <abbr class="timeago" title="{{created_at}}">#{$.format.date(note.created_at, "HH:mm:ss")}</abbr>
        <span class="wall-text">
        #{simpleFormat(note.body)}
        </span>
      </li>
      """
    $(html)

@Wall = Wall
