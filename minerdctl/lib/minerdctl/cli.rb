require 'json'

class Minerdctl::Cli
  COMMANDS = %w(status start stop list attach)

  def self.run
    if ARGV.count < 1
      warn "Usage: #{$0} <command> [args...]"
      warn "Available commands: #{COMMANDS.join(', ')}"
      exit(false)

    elsif !COMMANDS.include?(ARGV[0])
      warn "Unknown command '#{ARGV[0]}'"
      exit(false)
    end

    c = Minerdctl::Client.new('localhost', 5000)

    cli = new(c)
    cli.run_cmd(ARGV[0], ARGV[1..-1])
    cli.cleanup

  rescue Errno::ECONNREFUSED => e
    warn "#{e.message}"
    exit(false)
  end

  def initialize(client)
    @client = client
  end

  def cleanup
    @client.close
  end

  def run_cmd(cmd, args)
    method(:"run_#{cmd.downcase}").call(args)
  end

  def run_status(args)
    puts @client.status()
  end

  def run_start(args)
    if args.count < 2
      warn "Missing arguments <id> <command> [args...]"
      exit(false)
    end

    id, cmd = args

    puts @client.start(id, cmd, args[2..-1])
  end

  def run_stop(args)
    if args.count < 1
      warn "Missing argument <id>"
      exit(false)
    end

    puts @client.stop(args[0])
  end

  def run_list(args)
    fmt = '%10s %10s  %-18.16s %-25s %s'
    puts sprintf(fmt, 'ID', 'PID', 'TIME', 'CMD', 'ARGS')

    JSON.parse(@client.list.strip, symbolize_names: true).each do |cmd|
      puts sprintf(
        fmt,
        cmd[:id],
        cmd[:pid],
        format_duration(Time.now.to_i - cmd[:started_at]),
        cmd[:cmd],
        cmd[:args]
      )
    end
  end

  def run_attach(args)
    if args.count < 1
      warn "Missing argument <id>"
      exit(false)
    end

    ret = @client.attach(args[0]).strip

    if ret != 'OK'
      warn "Unable to attach #{args[0]}: #{ret}"
      exit(false)
    end

    i = Minerdctl::Interactive.new(@client.socket)
    i.start
  end

  protected
  def format_duration(interval)
    d = interval / 86400
    h = interval / 3600 % 24
    m = interval / 60 % 60
    s = interval % 60

    if d > 0
      "%d days, %02d:%02d:%02d" % [d, h, m, s]
    else
      "%02d:%02d:%02d" % [h, m, s]
    end
  end
end
