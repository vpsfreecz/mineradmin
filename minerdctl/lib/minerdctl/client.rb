require 'socket'

class Minerdctl::Client
  def initialize(host, port)
    @socket = TCPSocket.new(host, port)
  end

  def close
    @socket.close
  end

  def status
    cmd('STATUS')
  end

  def start(id, cmd, args)
    cmd('START', id, cmd, *args)
  end

  def stop(id)
    cmd('STOP', id)
  end

  def list
    cmd('LIST')
  end

  protected
  def cmd(cmd, *args)
    @socket.puts("#{cmd} #{args.join(' ')}")
    @socket.readline
  end
end
