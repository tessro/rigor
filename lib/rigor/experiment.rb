module Rigor
  class Experiment
    def self.find_by_name(name)
      Test.new
    end

    def treatments
      [Treatment.new(:control), Treatment.new(:test)]
    end

    def random_treatment
      treatment_max = 0
      assignment = rand(cumulative_weights)
      treatments.each do |treatment|
        treatment_max += treatment.weight
        return treatment if assignment < treatment_max
      end
    end

    protected

    def cumulative_weights
      treatments.map(&:weight).sum
    end
  end
end
