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
        treatment_name = if cookies[experiment_name]
                           cookies[experiment_name]
                         else
                           test = Rigor::Experiment.find_by_name(experiment_name)
                           treatment = test.random_treatment
                           treatment.record!
                           cookies[experiment_name] = treatment.name
                         end.to_s

        if block_given?
          capture(treatment_name, &block)
        else
          treatment_name
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
