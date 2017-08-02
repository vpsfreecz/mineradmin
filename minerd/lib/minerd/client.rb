require 'json'

class Minerd::Client
  def initialize(socket)
    @socket = socket
    @next_line = nil
  end

  def serve
    loop do
      if @next_line
        line = @next_line
        @next_line = nil

      else
        line = @socket.readline
      end

      begin
        msg = JSON.parse(line.strip, symbolize_names: true)
        process(msg[:cmd], msg[:opts] || {})

      rescue => e
        warn "Command error: #{e.message} (#{e.class})"
        warn e.backtrace.join("\n")

        reply('ERROR')
      end
    end

  rescue => e
    puts "Client disconnected: #{e.message} (#{e.class})"
    @socket.close unless @socket.closed?
  end

  def process(cmd, opts)
    puts "Command '#{cmd}', opts '#{opts}'"
    commands = %w(STATUS START STOP LIST ATTACH)

    unless commands.include?(cmd)
      reply('NOT UNDERSTOOD')
      return
    end

    method(:"cmd_#{cmd.downcase}").call(opts)
  end

  def cmd_status(opts)
    return reply(true) if opts[:id].nil?

    h = Minerd::State.handler_by_id(opts[:id])

    return reply(false, message: 'NOT FOUND') unless h
    reply(true, h.info)
  end

  def cmd_start(opts)
    if opts[:id].nil?
      return reply(false, message: 'MISSING ID')

    elsif opts[:cmd].nil?
      return reply(false, 'MISSING CMD')
    end

    Minerd::Handler.run(opts[:id].to_s, opts[:cmd], opts[:args] || [])
    reply(true)

  rescue Minerd::Handler::AlreadyStarted
    reply(false, message: 'ALREADY STARTED')
  end

  def cmd_stop(opts)
    if opts[:id].nil?
      reply(false, message: 'MISSING ID')
      return
    end

    h = Minerd::State.handler_by_id(opts[:id].to_s)

    if h
      h.stop
      reply(true)

    else
      reply(false, message: 'NOT FOUND')
    end
  end

  def cmd_list(opts)
    reply(true, Minerd::State.processes.map { |_, p| p.info })
  end

  def cmd_attach(opts)
    if opts[:id].nil?
      reply(false, 'MISSING ID')
      return
    end

    i = Minerd::Interactive.new(@socket, opts[:id].to_s)

    if i.subscribe
      reply(true)
      @next_line = i.start

    else
      reply(false, message: 'NOT FOUND')
    end
  end

  def reply(status, data = nil, message: nil)
    ret = {status: status}
    ret[:response] = data if data
    ret[:message] = message if message

    @socket.puts(JSON.dump(ret))
  end
end
