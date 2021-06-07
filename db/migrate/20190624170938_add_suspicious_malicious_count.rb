class AddSuspiciousMaliciousCount < ActiveRecord::Migration[5.2]
  def change
    add_column :devices, :suspicious_count, :int
    add_column :devices, :malicious_count, :int
    add_column :devices, :informational_count, :int

    change_column_default :devices, :suspicious_count, from: nil, to: 0
    change_column_default :devices, :malicious_count, from: nil, to: 0
    change_column_default :devices, :informational_count, from: nil, to: 0

    Device.find_each do |device|
      device.update_attributes(suspicious_count: Apps::Result.where(device: device).suspicious.count + HuntResult.unarchived.suspicious.where(device: device).count)
      device.update_attributes(malicious_count: Apps::Result.where(device: device).malicious.count + HuntResult.unarchived.malicious.where(device: device).count)
      device.update_attributes(informational_count: Apps::Result.where(device: device).informational.count + HuntResult.unarchived.informational.where(device: device).count)
    end
  end
end
