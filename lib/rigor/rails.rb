module Rigor
  class Railtie < ::Rails::Railtie
    initializer "rigor.load" do
      Rigor::Rails.load
    end
  end

  module Rails
    def load
    end
  end
end
