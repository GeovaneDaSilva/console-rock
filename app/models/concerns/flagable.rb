# Array columns as flags
module Flagable
  extend ActiveSupport::Concern

  class_methods do
    # as_flag :foos, :bar, :baz
    def as_flag(column, *flags)
      define_method "#{column}=" do |value|
        valid_values = Array.wrap(value).select { |v| flags.include?(v.to_s.to_sym) }

        super(valid_values)
      end

      define_method column do
        Array.wrap(super())
      end

      singularized_column = column.to_s.singularize
      define_singleton_method "#{singularized_column}_flags" do
        flags
      end

      flags.each do |flag|
        ### Instance Methods ###
        # Getter
        # bar_foo
        define_method "#{flag}_#{singularized_column}" do
          return false if send(column).nil?

          send(column).include?(flag.to_s)
        end

        # foo
        define_method flag.to_s do
          send("#{flag}_#{singularized_column}")
        end

        # foo?
        define_method "#{flag}?" do
          send("#{flag}_#{singularized_column}")
        end

        # bar_foo?
        define_method "#{flag}_#{singularized_column}?" do
          send("#{flag}_#{singularized_column}")
        end

        # Setter
        # bar_foo = true/false
        define_method "#{flag}_#{singularized_column}=" do |value|
          if ActiveRecord::Type::Boolean.new.cast(value)
            send(column) << flag.to_s
          else
            send(column).delete(flag)
          end
        end

        #### Scopes ####
        # with_bar_foo
        define_singleton_method "with_#{flag}_#{singularized_column}" do
          where("? = ANY (#{column})", flag)
        end

        # with_foos(:bar, :baz)
        define_singleton_method "with_#{column}" do |*query_flags|
          query_chain = where("? = ANY (#{column})", query_flags.shift)

          query_flags.each do |query_flag|
            query_chain = query_chain.or(
              where("? = ANY (#{column})", query_flag)
            )
          end

          query_chain
        end

        # with_all_foos(:bar, :baz)
        define_singleton_method "with_all_#{column}" do |*query_flags|
          query_chain = self
          query_flags.each do |query_flag|
            query_chain = query_chain.where("? = ANY (#{column})", query_flag)
          end

          query_chain
        end
      end
    end
  end
end
