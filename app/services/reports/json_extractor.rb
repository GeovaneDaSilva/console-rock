module Reports
  # Extract the given data from an object and serialize to json
  class JsonExtractor
    def initialize(object, attrs = [])
      @object = object
      @attrs = attrs
    end

    def call
      values = @attrs.map do |attr|
        [Array(attr).last, value_for_attr(attr)]
      end.to_h

      values.as_json
    end

    private

    def value_for_attr(attr)
      value = case attr
              when Array
                attr.inject(@object) { |obj, meth| obj.send(meth) }
              when Hash
                flat_attr = attr.flatten
                @object.send(flat_attr.first).dig(*flat_attr.last.flatten)
              else
                @object.send(attr)
              end
      value.is_a?(TestResults::BaseJson) ? subtree_as_json(value) : value
    end

    def subtree_as_json(subtree)
      subtree.as_json.map do |k, v|
        if v.is_a?(TestResults::BaseJson) || v.is_a?(Hash)
          [k, subtree_as_json(v)]
        else
          [k, v]
        end
      end.to_h
    end
  end
end
