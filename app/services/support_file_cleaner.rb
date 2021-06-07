# Trashes old Support File Uploads
class SupportFileCleaner
  def call
    return if AgentRelease.count.zero?

    Upload.support_files.find_each do |upload|
      upload.trashed! if AgentRelease.where("upload_ids @> '{#{upload.id}}'").none?
    end
  end
end
