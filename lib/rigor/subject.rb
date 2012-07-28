# TODO: handle race conditions:
# - when two parallel requests occur and there are treatment cookies
# - if both requests treat the user into the same experiment
# - generally, what race conditions exist during the request cycle, if saving
#   doesn't occur until the end?
module Rigor
  class Subject
    def initialize(object, prior = nil)
      @treatments = {}
      @object = object
      import_treatments_from(prior) if prior
    end

    attr_reader :treatments

    def treatment_for(experiment)
      @treatments[experiment.id] ||=
        Rigor.connection.find_existing_treatment(experiment, @object) ||
        experiment.random_treatment
    end

    def import_treatments_from(other)
      @treatments = treatments.merge(other.treatments)
    end

    def save
      treatments.each do |_, treatment|
        treatment.record!(@object)
      end
    end
  end
end
