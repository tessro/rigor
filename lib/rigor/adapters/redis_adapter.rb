module Rigor::Adapters
  class RedisAdapter
    def initialize(namespace)
      require 'redis-namespace'
      @redis = Redis::Namespace.new(namespace, :redis => Redis.new)
    end

    def record_treatment!(experiment, treatment)
      redis.hincrby("experiments:#{experiment.id}", "treatments:#{treatment.index}", 1)
    end

    def record_event!(treatment, event)
      redis.hincrby("experiments:#{treatment.experiment.id}", "treatments:#{treatment.index}:events:#{event}", 1)
    end

    protected

    attr_reader :redis
  end
end
