jQuery ->

window.Chat = {}

class Chat.User
  constructor: (@user_name, @guid) ->
  serialize: => { user_name: @user_name, guid: @guid }

class Chat.Controller
  template: (message) ->
    html =
      """
      <li class="message" >
        <label class="label label-info">
          [#{message.received}] #{message.user_name}
        </label>&nbsp;
        #{message.msg_body}
      </li>
      """
    $(html)

  userListTemplate: (userList) ->
    userHtml = ""
    for user in userList
      userHtml = userHtml + "<li>#{user.user_name}</li>"
    $(userHtml)

  constructor: (url,useWebSockets) ->
    @messageQueue = []
    @dispatcher = new WebSocketRails(url,useWebSockets)
    @dispatcher.on_open = @createGuestUser
    @bindEvents()

  bindEvents: =>
    @dispatcher.bind 'global_chat.new_message', @newMessage
    @dispatcher.bind 'global_chat.user_list', @updateUserList
    $('input#user_name').on 'keyup', @updateUserInfo
    $('#send').on 'click', @sendMessage
    $('#message').keypress (e) -> $('#send').click() if e.keyCode == 13

  newMessage: (message) =>
    @messageQueue.push message
    @shiftMessageQueue() if @messageQueue.length > 15
    @appendMessage message

  sendMessage: (event) =>
    event.preventDefault()
    message = $('#message').val()
    @dispatcher.trigger 'global_chat.new_message', {user_name: @user.user_name, msg_body: message}
    $('#message').val('')

  updateUserList: (userList) =>
    #$('#user-list').html @userListTemplate(userList)
    user_count = 0
    for user in userList
      user_count += 1
    $('#chat_users').html user_count

  updateUserInfo: (event) =>
    @user.user_name = $('input#user_name').val()
    $('#username').html @user.user_name
    @dispatcher.trigger 'global_chat.change_username', @user.serialize()

  appendMessage: (message) ->
    messageTemplate = @template(message)
    $('#chat ul.notes').append messageTemplate
    messageTemplate.slideDown 140

  shiftMessageQueue: =>
    @messageQueue.shift()
    $('#chat ul.li:first').slideDown 100, ->
      $(this).remove()

  createGuestUser: =>
    #rand_num = Math.floor(Math.random()*1000)
    @user = new Chat.User($('#chat').data('username'), 12)
    $('#username').html @user.user_name
    $('input#user_name').val @user.user_name
    @dispatcher.trigger 'global_chat.new_user', @user.serialize()