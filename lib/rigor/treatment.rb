module Rigor
  class Treatment
    def initialize(name, weight = 1)
      @name   = name
      @weight = weight
    end

    attr_reader :name
    attr_reader :weight
  end
end
