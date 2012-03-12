module Rigor
  module Rails
    class Session
      def initialize(request)
        @id = request.session_options[:id]
      end

      attr_reader :id
    end
  end
end
