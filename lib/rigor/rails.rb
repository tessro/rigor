require 'rigor/middleware'

module Rigor
  class Railtie < ::Rails::Railtie
    config.app_middleware.use ::Rigor::Middleware

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

    module Helpers
      def experiment(experiment_name)
        Rigor::Experiment.find_by_name(experiment_name)
      end

      def current_treatment(experiment_name, &block)
        session = Rigor::Rails::Session.new(request)
        treatment = experiment(experiment_name).treatment_for(session)

        if block_given?
          capture(treatment.name, &block)
        else
          treatment.name
        end
      end

      def record!(event)
        session = Rigor::Rails::Session.new(request)

        Experiment.all.each do |experiment|
          treatment = experiment.treatment_for(session)
          treatment.record_event!(event)
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
