module EventMachine
  module WebSocket
    class Handler13 < Handler
      include Handshake04
      include Framing07
      include MessageProcessor13
      include Close06
    end
  end
end
