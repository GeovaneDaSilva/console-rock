# Base class for archived app result uploads
class ResultArchive < ApplicationRecord
  belongs_to :upload
  belongs_to :customer
end
