class Minerd::Client
  def initialize(socket)
    @socket = socket
  end

  def serve
    loop do
      msg = @socket.readline.split(/\s/)

      begin
        process(msg[0], msg[1..-1])

      rescue => e
        warn "Command error: #{e.message} (#{e.class})"
        warn e.backtrace.join("\n")

        reply('ERROR')
      end
    end
  end

  def process(cmd, args)
    puts "Command '#{cmd}', args '#{args}'"
    commands = %w(STATUS START STOP LIST)

    unless commands.include?(cmd)
      reply('NOT UNDERSTOOD')
      return
    end

    method(:"cmd_#{cmd.downcase}").call(args)
  end

  def cmd_status(args)
    reply('OK')
  end

  def cmd_start(args)
    Minerd::Handler.run(args[0], args[1], args[2..-1])
    reply('OK')

  rescue Minerd::Handler::AlreadyStarted
    reply('ALREADY STARTED')
  end

  def cmd_stop(args)
    h = Minerd::State.handler_by_id(args[0])

    if h
      h.stop
      reply('OK')

    else
      reply('NOT FOUND')
    end
  end

  def cmd_list(args)
    reply(Minerd::State.processes.map do |id, p|
      "#{id}: cmd=#{p.cmd}"
    end.join("\n"))
  end

  def reply(msg)
    @socket.puts(msg)
  end
end
