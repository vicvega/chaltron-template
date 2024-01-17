module Chaltron
  module Filters
    module Scopeable
      # Define scope-like methods
      def scope(names)
        Array.wrap(names).each do |name|
          original = "_orig_#{name}"
          alias_method original, name
          define_method name do |*args, **kwargs|
            relation = send(original, *args, **kwargs)
            relation || self
          end
        end
      end
    end
  end
end
