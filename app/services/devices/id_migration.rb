module Devices
  # Updates a device pk to be the same as the Device#uuid
  # Updates foreign key on all has_many relations
  # Then updates the pk on the record
  class IdMigration
    def initialize(device)
      @device = device
    end

    def call
      # Rails.logger.info("ID migration for #{@device.id} to #{@device.uuid}")

      all_has_many_reflections.each do |name, reflection|
        @device.send(name).update_all(reflection.foreign_key => @device.uuid)
      end

      @device.update_column(:id, @device.uuid)
    end

    private

    def all_has_many_reflections
      Device.reflections.select do |_name, reflection|
        reflection.is_a?(ActiveRecord::Reflection::HasManyReflection)
      end
    end
  end
end
