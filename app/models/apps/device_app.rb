module Apps
  # :nodoc
  class DeviceApp < App
    belongs_to :upload

    validates :upload, :report_template, presence: true
  end
end
