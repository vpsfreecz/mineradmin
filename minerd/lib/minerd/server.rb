require 'socket'

class Minerd::Server
  def run
    path = '/run/minerd/minerd.sock'

    File.unlink(path) if File.exists?(path)
    @socket = UNIXServer.new(path)
    File.chmod(0660, path)

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
