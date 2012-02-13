module Rigor
  class Railtie < ::Rails::Railtie
    initializer "rigor.load" do
      Rigor::Rails.load!
    end
  end

  module Rails
    def self.load!
      Dir[::Rails.root.join('experiments', '*.rb')].each do |file|
        Rigor::Experiment.load_from(file)
      end
    end

    def cookies
      super.cookies[:_rigor_treatments] ||= {}
    end

    module Helpers
      def treatment(experiment_name, &block)
        experiment = Rigor::Experiment.find_by_name(experiment_name)
        treatment  = if cookies[experiment.id]
                       experiment.treatments[cookies[experiment.id]]
                     else
                       experiment.random_treatment.tap do |treatment|
                         treatment.record!
                         cookies[experiment.id] = treatment.index
                       end
                     end

        if block_given?
          capture(treatment.name, &block)
        else
          treatment.name
        end
      end
    end
  end
end

if defined?(ActionController::Base)
  ActionController::Base.class_eval do
    helper Rigor::Rails::Helpers
  end
end
