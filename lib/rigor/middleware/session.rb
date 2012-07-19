module Rigor
  class Middleware
    class Session
      def initialize(session)
        @session = session

        process_treatment_cookies
      end

      def load_treatment_cookies(cookies)
        Experiment.assign_all_from_hash(cookies)
      end
    end
  end
end
