module KubeAutoAnalyzer
require 'socket'

def self.is_port_open?(ip, port)
  begin
    Socket.tcp(ip, port, connect_timeout: 2)
  rescue Errno::ECONNREFUSED
    return false
  rescue Errno::ETIMEDOUT
    return false
  end
  true
end

end