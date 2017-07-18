require 'thread'

class Minerd::Handler
  class AlreadyStarted < StandardError ; end

  attr_accessor :id, :cmd, :args

  def self.run(id, cmd, args)
    h = new(id, cmd, args)
    Minerd::State.register(id, h)
    h.start
  end

  def initialize(id, cmd, args)
    @id = id
    @cmd = cmd
    @args = args
  end

  def start
    @thread = Thread.new do
      @io = IO.popen(wrapped, 'r+')
      puts "Process started with PID #{@io.pid}"

      until @io.eof?
        @io.readline
      end

      Process.wait(@io.pid)
      Minerd::State.unregister(@id)
    end
  end

  def stop
    @io.puts('Q')
  end

  def wrapped
    [wrapper] + [@cmd] + @args
  end

  def wrapper
    File.absolute_path(File.join(
      File.dirname(__FILE__),
      '..', '..',
      'bin', 'minerd-wrapper'
    ))
  end
end
