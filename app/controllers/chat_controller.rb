class ChatController < WebsocketRails::BaseController
  include ActionView::Helpers::SanitizeHelper

  def initialize_session

  end
  
  def system_msg(ev, msg)
    broadcast_message ev, { 
      user_name: 'system', 
      received: Time.now.to_s(:short), 
      msg_body: msg
      }, :namespace => :global_chat
  end
  
  def user_msg(ev, msg)
    broadcast_message ev, { 
      user_name:  connection_store[:user][:user_name], 
      received:   Time.now.to_s(:short), 
      msg_body:   ERB::Util.html_escape(msg)
      }, :namespace => :global_chat
  end
  
  def client_connected
    system_msg :new_message, "#{client_id} connected"
  end
  
  def new_message
    user_msg :new_message, message[:msg_body].dup
  end
  
  def new_user
    connection_store[:user] = { user_name: sanitize(message[:user_name]), guid: message[:guid] }
    broadcast_user_list
  end
  
  def change_username
    connection_store[:user][:user_name] = sanitize(message[:user_name])
    broadcast_user_list
  end
  
  def client_disconnected
    connection_store[:user] = nil
    system_msg :new_message, "#{current_user.name} disconnected"
    broadcast_user_list
  end
  
  def broadcast_user_list
    users = connection_store.collect_all(:user)
    broadcast_message :user_list, users, :namespace => :global_chat
  end
  
end
