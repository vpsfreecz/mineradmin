require 'socket'

class Minerdctl::Client
  attr_reader :socket

  def initialize(host, port)
    @socket = TCPSocket.new(host, port)
  end

  def close
    @socket.close
  end

  def status(id = nil)
    cmd('STATUS', *(id ? [id] : []))
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

  def attach(id)
    cmd('ATTACH', id)
  end

  protected
  def cmd(cmd, *args)
    @socket.puts("#{cmd} #{args.join(' ')}")
    @socket.readline.strip
  end
end
