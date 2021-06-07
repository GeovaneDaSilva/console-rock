# A device's crash report
class CrashReport < ApplicationRecord
  belongs_to :device
  belongs_to :upload
end
