module CivisApi
  module Exceptions
    class IncorrectOtp < StandardError
      def initialize(message = nil)
        @message = message
      end

      def message
        @message || "Incorrect OTP"
      end
    end

  end
end