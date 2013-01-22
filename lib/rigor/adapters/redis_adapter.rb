module Rigor::Adapters
  class RedisAdapter
    # Data model:
    #
    # Key: experiments:<experiment_id>:treatments:<treatment_id>:subjects
    # Type: set
    # Values: subject identifier
    #
    # Key: experiments:<experiment_id>:treatments:<treatment_id>:events:<event_name>
    # Type: hash
    # Values: subject_identifier => count
    def initialize(namespace)
      require 'redis-namespace'
      @redis = Redis::Namespace.new(namespace, :redis => Redis.new)
    end

    def record_treatment!(experiment, treatment, object)
      redis.sadd("experiments:#{experiment.id}:treatments:#{treatment.index}:subjects", generate_identifier(object))
    end

    def record_event!(treatment, object, event)
      redis.hincrby("experiments:#{treatment.experiment.id}:treatments:#{treatment.index}:events:#{event}", generate_identifier(object), 1)
    end

    def find_existing_treatment(experiment, object)
      experiment.treatments.find do |treatment|
        redis.sismember("experiments:#{experiment.id}:treatments:#{treatment.index}:subjects", generate_identifier(object))
      end
    end

    def treatment_size(treatment)
      experiment = treatment.experiment
      redis.scard("experiments:#{experiment.id}:treatments:#{treatment.index}:subjects")
    end

    def unique_events(treatment, event)
      experiment = treatment.experiment
      redis.hlen("experiments:#{experiment.id}:treatments:#{treatment.index}:events:#{event}")
    end

    # FIXME: Track total events separately to improve from O(N) to O(1).
    def total_events(treatment, event)
      experiment = treatment.experiment
      result = redis.hvals("experiments:#{experiment.id}:treatments:#{treatment.index}:events:#{event}")
      result.map(&:to_i).reduce(&:+)
    end

    # FIXME: this is linear on the number of subjects; could fix by tracking the
    # distribution separately, and using the events hash to figure out how to
    # alter the distribution in the face of new events (get old count, increment
    # the user's count, decrement distribution at old count, increment at new)
    # this fix would make this method linear on the cardinality of the
    # distribution, rather than the number of subjects, which is probably the
    # smaller value in most cases.
    def event_distribution(treatment, event)
      experiment = treatment.experiment
      result = redis.hvals("experiments:#{experiment.id}:treatments:#{treatment.index}:events:#{event}")
      distribution = result.map(&:to_i).reduce([]) do |arr, ct|
        arr[ct] ||= 0
        arr[ct]  += 1
        arr.map { |i| i || 0 }
      end
      distribution[0] = treatment_size(treatment) - unique_events(treatment, event)
      distribution
    end

    protected

    def generate_identifier(object)
      "#{object.class.name}:#{object.id}"
    end

    attr_reader :redis
  end
end
