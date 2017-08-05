require 'socket'
require 'json'

class Minerdctl::Client
  attr_reader :socket

  def initialize
    @socket = UNIXSocket.new('/run/minerd/minerd.sock')
  end

  def close
    @socket.close
  end

  def status(id = nil)
    cmd('STATUS', id ? {id: id} : {})
  end

  def start(id, cmd, args)
    cmd('START', {id: id, cmd: cmd, args: args})
  end

  def stop(id)
    cmd('STOP', {id: id})
  end

  def list
    cmd('LIST')
  end

  def attach(id)
    cmd('ATTACH', {id: id})
  end

  def detach(id)
    @socket.puts('Q')
  end

  protected
  def cmd(cmd, opts = {})
    @socket.puts(JSON.dump({cmd: cmd, opts: opts}))
    Minerdctl::Response.new(JSON.parse(@socket.readline.strip, symbolize_names: true))
  end
end
