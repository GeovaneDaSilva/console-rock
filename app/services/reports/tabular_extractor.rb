module Reports
  # Extract the given data from an object
  # Example:
  #     Reports::CsvExtractor.new(device_record, [:hostname, [:customer, :name]]).call
  #       => "srv12345,bigcustomer"
  class TabularExtractor
    def initialize(object, attrs = [], separator = ",")
      @object = object
      @attrs = attrs
      @separator = separator
    end

    def call
      values = @attrs.collect do |attr|
        value_for_attr(attr)
      end

      values.join(@separator)
    end

    private

    def value_for_attr(attr)
      case attr
      when Array
        attr.inject(@object) { |obj, meth| obj.send(meth) }
      when Hash
        flat_attr = attr.flatten
        if flat_attr.last.any? { |e| e.is_a? Array }
          flat_attr.last.each do |e|
            res = @object.send(flat_attr.first).dig(*e.flatten)
            return res if res
          end
          nil
        else
          @object.send(flat_attr.first).dig(*flat_attr.last.flatten)
        end
      else
        @object.send(attr)
      end
    end
  end
end
