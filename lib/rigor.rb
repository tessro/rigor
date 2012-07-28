require "rigor/version"
require "rigor/treatment"
require "rigor/experiment"
require "rigor/adapters"
require "rigor/subject"

# Frameworks
require "rigor/rails" if defined?(Rails::Railtie)

module Rigor
  class << self
    def connection
      @connection ||= Rigor::Adapters::RedisAdapter.new("rigor")
    end

    # The test subject
    attr_accessor :subject

    def identify_subject(object)
      Rigor.subject = Rigor::Subject.new(object, Rigor.subject)
    end
  end
end
