module Rigor::Adapters
  class RedisAdapter
    def initialize(namespace)
      require 'redis-namespace'
      @redis = Redis::Namespace.new(namespace, :redis => Redis.new)
    end

    def record_treatment!(experiment, treatment)
      redis.hincrby("experiments:#{experiment.id}", "treatments:#{treatment.index}", 1)
    end

    def record_event!(event, treatments)
      treatments.each do |treatment|
        redis.hincrby("experiments:#{treatment.experiment.id}", "events:#{event}", 1)
      end
    end

    protected

    attr_reader :redis
  end
end
