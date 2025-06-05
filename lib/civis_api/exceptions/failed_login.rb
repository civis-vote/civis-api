module CivisApi
  module Exceptions
    class FailedLogin < StandardError
      def initialize(message = nil)
        @message = message
      end

      def message
        @message || "Email not found"
      end
    end

  end
end