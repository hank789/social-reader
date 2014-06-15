module Notes
  class CreateService < BaseService
    def execute
      chat_type = params[:chat_type]
      note = Note.new()
      note.post_id = post
      note.user = current_user
      note.system = false
      note.noteable_type = chat_type
      note.note = params[:note]
      case chat_type
        when 'GlobalChat'
          post_object = Post.find(post)
          post_object.gloabl_share_to_chat_count += 1
          post_object.save
          note.noteable_id = post
          note.post_id = -1
          note_title =  post_object.title
          if post_object.title.empty?
            note_title =  post_object.description
          end
          note.note = "Shared a post: <a href= '#{post_object.link}' target='_blank'>#{note_title}</a>"
      end
      note.save
      note
    end
  end
end
