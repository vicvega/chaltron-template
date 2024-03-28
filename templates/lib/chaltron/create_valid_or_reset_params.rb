module Chaltron
  module CreateValidOrResetParams
    def create_valid(...)
      object = new(...)
      return object if object.valid?

      new
    end
  end
end
