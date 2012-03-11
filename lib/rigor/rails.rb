require 'rigor/middleware'
require 'rigor/rails/cookie_jar'

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
      def treatment_cookies
        Rigor::Rails::CookieJar.new(cookies)
      end

      def experiment(experiment_name)
        Rigor::Experiment.find_by_name(experiment_name)
      end

      def current_treatment(experiment_name, &block)
        session = Struct.new("Session", :id).new(request.session_options[:id])
        treatment = experiment(experiment_name).treatment_for(session)

        if block_given?
          capture(treatment.name, &block)
        else
          treatment.name
        end
      end

      def record!(event)
        treatment_cookies.each do |experiment_id, treatment_idx|
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
