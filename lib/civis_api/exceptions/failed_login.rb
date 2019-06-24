module CivisApi
  module Exceptions
    class FailedLogin < StandardError
      def initialize(message = nil)
        @message = message
      end

      def message
        @message || "Incorrect email/password combination"
      end
    end

  end
end