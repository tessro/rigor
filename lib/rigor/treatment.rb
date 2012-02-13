module Rigor
  class Treatment
    def initialize(name, attributes = {})
      @name   = name
      @weight = attributes.delete(:weight) || 1
      @attributes = attributes
    end

    attr_reader :name
    attr_reader :weight
    attr_reader :attributes
  end
end
