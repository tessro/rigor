module Rigor
  class Experiment
    def self.load_from(filename)
      instance_eval(File.read(filename)).tap do |e|
        e.id = Pathname.new(filename).basename.to_s.to_i
        @experiments ||= {}
        @experiments[e.id] = e
      end
    end

    def self.experiment(name, &block)
      new(name).tap do |e|
        DSL.new(e).instance_eval(&block)
      end
    end

    def self.all
      @experiments
    end

    def self.find_by_id(id)
      all[id.to_i]
    end

    def self.find_by_name(name)
      all.values.find { |e| e.name == name }
    end

    def self.assign_all(hash)
    end

    def initialize(name)
      @name = name
      @treatments = []
    end

    attr_accessor :id
    attr_accessor :name
    attr_accessor :description
    attr_accessor :identity_method
    attr_reader :treatments

    def add_treatment(treatment)
      treatment.experiment = self
      treatment.index = @treatments.length
      @treatments << treatment
      treatment
    end

    def random_treatment
      treatment_max = 0
      assignment = rand(cumulative_weights)
      treatments.each do |treatment|
        treatment_max += treatment.weight
        return treatment if assignment < treatment_max
      end
    end

    def treatment_for(subject)
      Rigor.connection.find_existing_treatment(self, subject) || random_treatment.tap do |treatment|
        treatment.record!(subject)
      end
    end

    protected

    def cumulative_weights
      treatments.map(&:weight).sum
    end

    class DSL
      def initialize(experiment)
        @experiment = experiment
      end

      def identity(method)
        @experiment.identity_method = method
      end

      def description(description)
        @experiment.description = description
      end

      def treatment(name, options = {})
        @experiment.add_treatment(Treatment.new(name, options))
      end
    end
  end
end
