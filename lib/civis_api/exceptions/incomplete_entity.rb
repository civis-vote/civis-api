module CivisApi
  module Exceptions
    class IncompleteEntity < StandardError
      def initialize(message = nil)
        @message = message
      end

      def message
        @message || "Entity is incomplete, cannot perform operation."
      end
    end

  end
end