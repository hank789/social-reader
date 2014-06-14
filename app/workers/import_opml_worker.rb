class ImportOpmlWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(tmp_id)
    tmpfile= TmpFile.find(tmp_id)
    user = User.find(tmpfile.user_id)
    ImportFromOpml.import(tmpfile.note, user)
  end
end