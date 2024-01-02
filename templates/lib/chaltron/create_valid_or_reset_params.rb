module Chaltron
  module CreateValidOrResetParams
    def create(...)
      object = new(...)
      return object if object.valid?

      new
    end
  end
end
