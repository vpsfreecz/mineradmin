require 'thread'

class Minerd::State
  class << self
    def get
      return @instance if @instance
      @instance = new
    end

    def register(*args)
      get.register(*args)
    end

    def unregister(*args)
      get.unregister(*args)
    end

    def processes
      get.processes
    end

    def handler_by_id(*args)
      get.handler_by_id(*args)
    end
  end

  private
  def initialize
    @mutex = Mutex.new
    @processes = {}
  end

  public
  def register(id, handler)
    sync do
      if @processes.has_key?(id)
        raise Minerd::Handler::AlreadyStarted, "handler for '#{id}' is already registered"

      else
        @processes[id] = handler
      end
    end
  end

  def unregister(id)
    sync { @processes.delete(id) }
  end

  def processes
    sync { @processes.clone }
  end

  def handler_by_id(id)
    sync { @processes[id] }
  end

  def sync
    @mutex.synchronize { yield }
  end
end
