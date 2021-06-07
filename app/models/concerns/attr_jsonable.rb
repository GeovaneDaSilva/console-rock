# Make json field values feel like real columns
module AttrJsonable
  extend ActiveSupport::Concern

  class_methods do
    def attr_json_accessor(column_name, *keys)
      attr_json_writer(column_name, *keys)
      attr_json_reader(column_name, *keys)
    end

    def attr_json_reader(column_name, *keys)
      keys.each do |key|
        define_method(key) do
          get_key_value_for_json_column(column_name, key)
        end
      end
    end

    def attr_json_writer(column_name, *keys)
      keys.each do |key|
        define_method("#{key}=") do |value|
          set_key_value_for_json_column(column_name, key, value)
        end
      end
    end
  end

  def set_key_value_for_json_column(column_name, key, value)
    column_value = send(column_name) || {}
    column_value[key] = value

    send("#{column_name}=", column_value)
  end

  def get_key_value_for_json_column(column_name, key)
    column_value = (send(column_name) || {}).with_indifferent_access
    column_value.dig(key)
  end
end
