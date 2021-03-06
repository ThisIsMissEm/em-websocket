module EventMachine
  module WebSocket
    class WebSocketError < RuntimeError; end
    class HandshakeError < WebSocketError; end
    class DataError < WebSocketError
      attr_accessor :close_code
    end

    def self.start(options, &blk)
      EM.epoll
      EM.run do

        trap("TERM") { stop }
        trap("INT")  { stop }

        EventMachine::start_server(options[:host], options[:port],
          EventMachine::WebSocket::Connection, options) do |c|
          blk.call(c)
        end
      end
    end

    def self.stop
      puts "Terminating WebSocket Server"
      EventMachine.stop
    end
  end
end
