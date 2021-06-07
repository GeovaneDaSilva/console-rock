# :nodoc
module Apps
  def self.table_name_prefix
    "apps_"
  end
end

require "apps/device_app"
require "apps/cloud_app"
require "apps/office365_app"

require "apps/device_result"
require "apps/cloud_result"
require "apps/office365_result"
