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
                       experiment.treatments[cookies[experiment.id].to_i]
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

      def record!(event)
        cookies.each do |experiment_id, treatment_idx|
          experiment = Rigor::Experiment.find_by_id(experiment_id)
          if experiment
            treatment = experiment.treatments[treatment_idx.to_i]
            treatment.record_event!(event) if treatment
          end
        end
        nil
      end
    end
  end
end

if defined?(ActionController::Base)
  ActionController::Base.class_eval do
    helper Rigor::Rails::Helpers
  end
end
