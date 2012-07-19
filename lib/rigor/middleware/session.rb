module Rigor
  class Middleware
    class Session
      def initialize(session_id)
        @session_id = session_id
      end

      def id
        @session_id
      end

      def load_treatment_cookies(cookies)
        Experiment.assign_all_from_hash(cookies)
      end
    end
  end
end
