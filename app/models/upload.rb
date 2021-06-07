# Represents any uploaded object
class Upload < ApplicationRecord
  include Flagable

  as_flag :tags, :pe, :body_dump

  belongs_to :sourceable, polymorphic: true
  has_many :hunt_results, dependent: :restrict_with_error
  has_one :agent_log, class_name: "Devices::AgentLog", dependent: :destroy
  has_one :provider, foreign_key: "logo_id", dependent: :nullify

  enum status: {
    presigned: 0,
    completed: 1,
    trashed:   2
  }

  validates :status, :filename, :size, presence: true

  # :o
  default_scope { order(:created_at) }
  scope :support_files, -> { where(support_file: true).completed }
  scope :protected_files, -> { where(protected: true) }
  scope :not_protected_files, -> { where(protected: false) }

  def destroy
    if completed?
      trashed!
    else
      super
    end
  end

  def key
    "#{id}/#{filename}"
  end

  def extension
    filename.split(".").last
  end

  def mime_type
    Mime::Type.lookup_by_extension(extension) || "application/octet-stream"
  end

  def url
    object.presigned_url(:get, expires_in: 6.days.to_i)
  end

  def object
    bucket.object(key)
  end

  def as_data
    Rails.cache.fetch(["v1/upload-data", self]) do
      Uploads::Downloader.new(self).call.read
    end
  end

  def md5
    Rails.cache.fetch("uploads/#{key}/md5") { object.etag.delete(%(")) }
  end

  def bucket
    @bucket ||= Aws::S3::Resource.new.bucket(ENV["AWS_S3_BUCKET"])
  end
end
