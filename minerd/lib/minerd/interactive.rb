require 'base64'
require 'thread'

class Minerd::Interactive
  def initialize(socket, id)
    @mutex = Mutex.new
    @socket = socket
    @id = id
    @exited = false
  end

  def subscribe
    @handler = Minerd::State.handler_subscribe(@id, self) do |event, data|
      case event
      when :data
        @socket.send("W #{Base64.strict_encode64(data)}\n", 0)

      when :exit
        @socket.send("Q #{data}\n", 0)
        sync { @exited = true }
      end
    end
  end

  def start
    loop do
      line = @socket.readline.strip

      return line if sync { @exited }
      next if line.empty?

      msg = line.split(' ')

      if msg.count < 1
        warn "Invalid interactive cmd '#{line}'"
        next
      end

      case msg[0]
      when 'W'
        if msg[1].nil?
          warn "Invalid empty write"
          next
        end

        @handler.write(msg[1])

      when 'S'
        if !msg[1] || !msg[2]
          warn "Invalid dimensions #{msg[1]}x#{msg[2]}"
          next
        end

        @handler.resize(msg[1], msg[2])

      when 'Q'
        break

      else
        warn "Invalid interactive cmd '#{msg[0]}'"
        next
      end
    end

    nil

  rescue => e
    warn "Exception in interactive mode: #{e.message} (#{e.class})"

  ensure
    Minerd::State.handler_unsubscribe(@id, self)
  end

  def sync
    @mutex.synchronize { yield }
  end
end
