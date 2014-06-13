module Notes
  class CreateService < BaseService
    def execute
      note = Note.new(params[:note])
      note.post_id = -1
      note.user = current_user
      note.system = false
      note.save
      note
    end
  end
end
