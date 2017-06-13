module KubeAutoAnalyzer
require 'socket'

def self.is_port_open?(ip, port)
  s = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
  sa = Socket.sockaddr_in(port, ip)

  begin
    s.connect_nonblock(sa)
  rescue Errno::EINPROGRESS
    if IO.select(nil, [s], nil, 1)
      begin
        s.connect_nonblock(sa)
      rescue Errno::EISCONN
        return true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        return false
      end
    end
  end

  return false
end

end