# encoding: BINARY

module EventMachine
  module WebSocket
    # The only difference between draft 03 framing and draft 04 framing is 
    # that the MORE bit has been changed to a FIN bit
    module Framing13
      include Framing07

      private
      
      def maximum_frame_length_error_code
        1009
      end
    end
  end
end