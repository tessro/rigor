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

    def record!(object)
      Rigor.connection.record_treatment!(experiment, self, object)
    end

    def record_event!(event, object)
      Rigor.connection.record_event!(self, object, event)
    end
  end
end
