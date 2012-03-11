module Rigor::Adapters
  class RedisAdapter
    def initialize(namespace)
      require 'redis-namespace'
      @redis = Redis::Namespace.new(namespace, :redis => Redis.new)
    end

    def record_treatment!(experiment, treatment, object)
      redis.sadd("experiments:#{experiment.id}:treatments:#{treatment.index}:subjects", generate_identifier(object))
    end

    def record_event!(treatment, event)
      redis.hincrby("experiments:#{treatment.experiment.id}", "treatments:#{treatment.index}:events:#{event}", 1)
    end

    def find_existing_treatment(experiment, object)
      experiment.treatments.find do |treatment|
        redis.sismember("experiments:#{experiment.id}:treatments:#{treatment.index}:subjects", generate_identifier(object))
      end
    end

    protected

    def generate_identifier(object)
      "#{object.class.name}:#{object.id}"
    end

    attr_reader :redis
  end
end
