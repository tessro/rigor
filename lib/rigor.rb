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

  # The test subject
  cattr_accessor :subject

  def self.identify_subject(object)
    Rigor.subject.become(object) || (Rigor.subject = Rigor::Subject.new(object))
  end
end
