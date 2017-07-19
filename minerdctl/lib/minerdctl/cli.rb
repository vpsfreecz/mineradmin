class Minerdctl::Cli
  COMMANDS = %w(status start stop list)

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
    puts @client.list.split(';').join("\n")
  end
end
