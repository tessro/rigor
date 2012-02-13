require "rigor/version"
require "rigor/treatment"
require "rigor/experiment"
require "rigor/adapters"

# Frameworks
require "rigor/rails" if defined?(Rails::Railtie)

module Rigor
  def self.connection
    @connection ||= Rigor::Adapters::RedisAdapter.new("rigor")
  end
end
