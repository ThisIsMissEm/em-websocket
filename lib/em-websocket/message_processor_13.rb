module EventMachine
  module WebSocket
    module MessageProcessor13
      def invalid_encoding_error_code
        1007
      end

      include MessageProcessor06
    end
  end
end