# Enables the use of `let` syntax on controllers
module Lettable
  def let(name, &blk)
    iv = "@#{name}"

    # create the method on the controller
    define_method name do
      return instance_variable_get iv if instance_variable_defined? iv

      instance_variable_set iv, instance_eval(&blk)
    end

    # add the method as a helper for the view
    helper_method name

    define_method :"#{name}=" do |value|
      instance_variable_set iv, value
    end

    # prevent writing to the attribute on the view
    private :"#{name}="
  end
end
