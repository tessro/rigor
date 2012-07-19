# maybe we should store all treatments in a hash on the subject identifier
# we could just load up all the existing treatments when the first read or write happens
# Subject#become would port all these treatments to the new identifier
# Subject#save would persist cookie treatments
# - this is still ugly... we don't know where to store these until
#   Rigor.identify_subject is called. we could store them proactively but that
#   would mean porting them to the new identifier 100% of the time in most cases
# - actually this is only a problem when there are treatment cookies, which
#   should only persist for one request... but we should probably still do all
#   the saving at the end of the request cycle, so that any treating that
#   happens before the final identify_subject call gets assigned to the
#   canonical subject
# - this has its own flaws... what if there's a second, shorter request? do we
#   want to wait until this request finishes entirely, before persisting
#   anything? maybe it's an okay tradeoff, but worth contemplating...
# - also, in a perfect world, once the user's been identified via
#   identify_subject, we'd update the rigor cookie ID so that on future requests
#   from this session, we can update the user rather than create a temporary
#   session (and deal with porting it). the issue here will be doing this
#   securely, e.g. knowing when the user has screwed with it, and making sure
#   the data stored in the cookie is okay for the user to see. maybe a secure
#   cookie (write-safe) with a hash of the user's class-id pair? similarly,
#   maybe we should use GUIDs for both temp-session subjects and user subjects,
#   rather than a class-id scheme... then it's just a matter of substituting the
#   permanent one (computed from the actual subject) for the temporary one, once
#   we know it (as well as copying over any treatments from the temporary one)
# - the driving thought exercise is, how do we avoid/minimize treating the user's
#   temporary subject, right before their real one gets identified? since this
#   can cause the user to see multiple treatments (and is more I/O)
module Rigor
  class Subject
    def initialize(object, options = {})
      @object = object
      process_treatment_cookies(options.delete(:treatment_cookies)) if options[:treatment_cookies]
    end

    attr_reader :id

    def treatment_for(experiment)
      experiment.treatment_for(self)
    end

    def become(object)
      @object = object
    end

    def save
      save_treatments
    end
  end
end
