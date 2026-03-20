require 'pathname'

root_pathname = Pathname.new(__FILE__).expand_path.parent.parent

require root_pathname.join('lib', 'web-socket-ruby.rb').to_s

server_thread = Thread.new {
  websocket_server = WebSocketServer.new(
    accepted_domains: ['127.0.0.1', 'localhost'],
    port: 4638,
    secure: true,
    secure_certificate_file: '/etc/httpd/ssl/active_ssl_crt',
    secure_private_key_file: '/etc/httpd/ssl/active_ssl_key',
    secure_extra_chain_certs: '/home/jcarson/work/2026-03-20/monmouth-wildcard.com-CA.crt'
  )

  websocket_server.run do |client_connection|
    puts "[\033[0;35mSERVER\033[0;0m] - Client Connected"
    case client_connection.path
    when '/'
      client_connection.handshake

      while client_data = client_connection.receive
        puts "[\033[0;35mSERVER\033[0;0m] - Received '#{client_data}'"
      end
    end
  end
}

client_thread = Thread.new {
  websocket = WebSocket.new("wss://localhost:4638/")

  loop {
    data_to_send = Time.now.strftime('%s')
    puts "[\033[0;33mCLIENT\033[0;0m] - Sending '#{data_to_send}'"
    websocket.send(data_to_send)
    sleep 1
  }
}

server_thread.join
client_thread.join
