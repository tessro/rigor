# TODO: handle race conditions:
# - when two parallel requests occur and there are treatment cookies
# - if both requests treat the user into the same experiment
# - generally, what race conditions exist during the request cycle, if saving
#   doesn't occur until the end?
module Rigor
  class Subject
    def initialize(object, prior = nil)
      @object = object
      import_treatments_from(prior) if prior
    end

    def treatment_for(experiment)
      experiment.treatment_for(@object)
    end

    def save
      # save_treatments
    end
  end
end
