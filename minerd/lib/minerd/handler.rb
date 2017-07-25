require 'thread'

class Minerd::Handler
  class AlreadyStarted < StandardError ; end

  attr_accessor :id, :cmd, :args, :started_at

  def self.run(id, cmd, args)
    h = new(id, cmd, args)
    Minerd::State.register(id, h)
    h.start
  end

  def initialize(id, cmd, args)
    @mutex = Mutex.new
    @id = id
    @cmd = cmd
    @args = args
    @subscribers = []
  end

  def start
    @thread = Thread.new do
      @started_at = Time.now
      @io = IO.popen(wrapped, 'r+')
      puts "Process started with PID #{@io.pid}"

      until @io.eof?
        distribute(@io.readpartial(512))
      end

      Process.wait(@io.pid)
      Minerd::State.unregister(@id)
      sync { unsubscribe_all(:exit) }
    end
  end

  def stop
    sync do
      @io.puts('Q')
      unsubscribe_all(:exit)
    end
  end

  def write(data)
    sync { @io.puts("W #{data}") }
  end

  def resize(w, h)
    sync { @io.puts("S #{w} #{h}") }
  end

  def subscribe(subscriber, block)
    sync { @subscribers << [subscriber, block] }
  end

  def unsubscribe(subscriber)
    sync do
      @subscribers.delete_if do |sub, _|
        sub == subscriber
      end
    end
  end

  def info
    sync do
      {id: id, cmd: cmd, args: args, pid: @io.pid, started_at: @started_at.to_i}
    end
  end

  protected
  def distribute(data)
    sync { @subscribers.each { |_, block| block.call(:data, data) } }
  end

  def unsubscribe_all(reason)
    @subscribers.each { |_, block| block.call(:exit, nil) }
    @subscribers.clear
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

  def sync
    @mutex.synchronize { yield }
  end
end
