class Minerd::Interactive
  def initialize(socket, id)
    @socket = socket
    @id = id
  end

  def subscribe
    @handler = Minerd::State.handler_subscribe(@id, self) do |data|
      @socket.send(data, 0)
    end
  end

  def start
    loop do
      line = @socket.readline.strip
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

  rescue EOFError

  ensure
    Minerd::State.handler_unsubscribe(@id, self)
  end
end
