module Chaltron
  module Filters
    module Scopeable
      # Define a scope-like method from a given block
      def scope(name, block)
        define_method name do |*args, **kwargs|
          relation = instance_exec(*args, **kwargs, &block)
          relation || self
        end
      end
    end
  end
end
