module Apps
  # :nodoc
  class CloudResult < Result
    belongs_to :credential, optional: true
  end
end
