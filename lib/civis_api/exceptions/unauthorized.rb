module CivisApi
  module Exceptions
    class Unauthorized < StandardError
      def initialize(message = nil)
        @message = message
      end

      def message
        @message || "Invalid Access Token"
      end
    end

  end
end