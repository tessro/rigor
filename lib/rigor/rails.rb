module Rigor
  class Railtie < ::Rails::Railtie
    initializer "rigor.load" do
      Rigor::Rails.load!
    end
  end

  module Rails
    def self.load!
    end

    module Helpers
      def treatment(test_name, &block)
        test = Rigor::Test.find_by_name(test_name)
        treatment = test.random_treatment

        if block_given?
          capture(treatment, &block)
        else
          treatment
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
