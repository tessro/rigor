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

    def size
      Rigor.connection.treatment_size(self)
    end

    def total_events(event)
      Rigor.connection.total_events(self, event)
    end

    def unique_events(event)
      Rigor.connection.unique_events(self, event)
    end

    def event_distribution(event)
      Rigor.connection.event_distribution(self, event)
    end

    def record!(object)
      Rigor.connection.record_treatment!(experiment, self, object)
    end

    def record_event!(event, object)
      Rigor.connection.record_event!(self, object, event)
    end

    def variance(event)
      dist = event_distribution(event)
      m = mean(event)
      dist.each_with_index.reduce(0.0) { |sse, d| sse + d[0] * (d[1] - m) ** 2 } / size
    end

    def mean(event)
      total_events(event).to_f / size
    end

    def proportion(event)
      unique_events(event).to_f / size
    end

    def z_value(event, control)
      se_diff = Math.sqrt(variance(event) / size + control.variance(event) / control.size)
      (mean(event) - control.mean(event)) / se_diff
    end

    def unique_z_value(event, control)
      pooled_p = (unique_events(event) + control.unique_events(event)).to_f / (size + control.size)
      diff_p = proportion(event) - control.proportion(event)
      diff_p / Math.sqrt(pooled_p * (1 - pooled_p) * (1 / size.to_f + 1 / control.size.to_f))
    end
  end
end
