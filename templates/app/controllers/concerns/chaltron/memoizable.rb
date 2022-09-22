module Chaltron
  module Memoizable
    # simple memoization method
    def memoize(name, &block)
      var_name = "@#{name}".to_sym
      return instance_variable_get(var_name) if instance_variable_get(var_name).present?

      value = block.call
      instance_variable_set(var_name, value)
    end
  end
end
