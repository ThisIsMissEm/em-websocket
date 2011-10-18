# encoding: UTF-8

require 'helper'
require 'integration/shared_examples'

describe "draft13" do
  include EM::SpecHelper
  default_timeout 1

  before :each do
    @request = {
      :port => 80,
      :method => "GET",
      :path => "/demo",
      :headers => {
        'Host' => 'example.com',
        'Upgrade' => 'websocket',
        'Connection' => 'Upgrade',
        'Sec-WebSocket-Key' => 'dGhlIHNhbXBsZSBub25jZQ==',
        'Sec-WebSocket-Protocol' => 'sample',
        'Sec-WebSocket-Origin' => 'http://example.com',
        'Sec-WebSocket-Version' => '13'
      }
    }

    @response = {
      :protocol => "HTTP/1.1 101 Switching Protocols\r\n",
      :headers => {
        "Upgrade" => "websocket",
        "Connection" => "Upgrade",
        "Sec-WebSocket-Accept" => "s3pPLMBiTxaQ9kYGzzhZRbK+xOo=",
      }
    }
  end

  def start_server
    EM::WebSocket.start(:host => "0.0.0.0", :port => 12345) { |ws|
      yield ws
    }
  end

  def start_client
    client = EM.connect('0.0.0.0', 12345, Draft07FakeWebSocketClient)
    client.send_data(format_request(@request))
    yield client if block_given?
  end

  it_behaves_like "a websocket server" do; end

  it "should send back the correct handshake response" do
    em {
      EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 12345) { }

      # Create a fake client which sends draft 07 handshake
      # connection = EM.connect('0.0.0.0', 12345, Draft07FakeWebSocketClient)
      # connection.send_data(format_request(@request))

      start_client { |client|
        client.onopen {
          client.handshake_response.lines.sort.
            should == format_response(@response).lines.sort
            done
        }
      }
    }
  end

  if "a".respond_to?(:force_encoding)
    it "should send back an error code of 1007 if sent invalid UTF8 data" do
      em {
        start_server { }

        # Create a fake client which sends draft 07 handshake
        start_client { |client|
          client.onopen {
            # Create a string which claims to be UTF-8 but which is not
            s = "ê" # utf-8 string
            s.encode!("ISO-8859-1")
            s.force_encoding("UTF-8")
            s.valid_encoding?.should == false # now invalid utf8


            s.force_encoding("BINARY")
            client.send(s)
          }

          client.onmessage { |frame|
            if frame == "\x88\x02\x03\xEF".force_encoding('BINARY')
              done
            else
              fail
            end
          }
        }
      }
    end
  end
end
