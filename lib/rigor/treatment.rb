module Rigor
  class Treatment
    def initialize(name, attributes = {})
      @name   = name
      @weight = attributes.delete(:weight) || 1
      @attributes = attributes
    end

    attr_accessor :experiment
    attr_accessor :index

    attr_reader :name
    attr_reader :weight
    attr_reader :attributes

    def record!
      Rigor.connection.record_treatment!(experiment, self)
    end
  end
end
