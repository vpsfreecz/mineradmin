require 'socket'

class Minerd::Server
  def run
    @socket = UNIXServer.new('/run/minerd/minerd.sock')
    File.chmod(0660, '/run/minerd/minerd.sock')

    loop do
      s = @socket.accept

      Thread.new do
        c = Minerd::Client.new(s)
        c.serve
      end
    end
  end

  def stop
    @socket.close
    puts 'Socket closed..'
  end
end
