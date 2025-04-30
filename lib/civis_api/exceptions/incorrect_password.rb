module CivisApi
  module Exceptions
    class IncorrectPassword < StandardError
      def initialize(message = nil)
        @message = message
      end

      def message
        @message || "Incorrect old password"
      end
    end

  end
end