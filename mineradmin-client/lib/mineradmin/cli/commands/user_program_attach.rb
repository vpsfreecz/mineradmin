require 'eventmachine'
require 'websocket-eventmachine-client'
require 'base64'
require 'terminal-size'

module MinerAdmin::CLI::Commands
  class UserProgramAttach < HaveAPI::CLI::Command
    cmd :userprogram, :attach
    args 'USER_PROGRAM_ID'
    desc "Attach user program's terminal"

    class InputHandler < EventMachine::Connection
      attr_accessor :buffer

      def initialize(ws)
        @ws = ws
        @private_buffer = ''
        @buffer = ''
        @end_seq = ["\x01", "d"] # screen style
        #@end_seq = ["\x02", "d"] # tmux style
        @end_i = 0
      end

      # Data is checked on the presence of the end sequence. The first character
      # in the sequence (ENTER) can be read multiple times in a row and it is
      # to be forwarded.
      #
      # When the second character in the end sequence is read, it is not forwarded,
      # but stored in a private buffer. If the sequence is later broken, the private
      # buffer is forwarded and reset.
      #
      # If the whole end sequence is read, EM event loop is stopped.
      def receive_data(data)
        data.each_char do |char|
          if char == @end_seq[ @end_i ]
            if @end_i == @end_seq.size-1
              @ws.close
              EM.stop
              return
            end

            @end_i += 1

            if @end_i == 1
              @private_buffer += char

            else
              @buffer += char
            end

          elsif char == @end_seq.first
            @private_buffer += char

          else
            @end_i = 0

            unless @private_buffer.empty?
              @buffer += @private_buffer
              @private_buffer.clear
            end

            @buffer += char
          end
        end

        @ws.send_write(@buffer)
        @buffer.clear
      end
    end

    class WebSocketHandler < WebSocket::EventMachine::Client
      attr_accessor :read_only

      def send_write(data)
        return if read_only
        return if data.empty?
        send_cmd('W', Base64.strict_encode64(data))
      end

      def resize
        size = Terminal.size!
        send_cmd('S', size[:width], size[:height])
      end

      protected
      def send_cmd(cmd, *args)
        send("#{cmd} #{args.join(' ')}\n")
      end
    end

    def initialize(*args)
      super
      @opts = {}
    end

    def options(opts)
      opts.on('-r', '--read-only', 'Do not send any input to the attached program') do
        @opts[:ro] = true
      end

      opts.on('--[no-]tty', 'Toggle TTY control') do |tty|
        @opts[:tty] = tty
      end
    end

    def exec(args)
      if args.empty?
        puts "provide user program ID as an argument"
        exit(false)
      end

      user_prog = @api.userprogram.show(args[0].strip)

      tty do
        EventMachine.run do
          ws = WebSocketHandler.connect(
            uri: File.join(
              @api.communicator.url,
              "user-program-io?user_program=#{user_prog.id}"
            ),
            headers: auth_headers
          )

          ws.read_only = user_prog.read_only ? true : @opts[:ro]

          ws.onopen do
            ws.resize
          end

          ws.onmessage do |msg, type|
            $stdout.write(msg)
            $stdout.flush
          end

          ws.onerror do |error|
            reset_tty
            warn "Error occurred: #{error}"

            if error == "invalid_status_code"
              warn "\nPossible reasons:"
              warn "  - Authentication failure, i.e. incorrect username or password"
              warn "  - Invalid user program ID"
            end

            EM.stop
          end

          ws.onclose do |code, reason|
            EM.stop
          end

          EventMachine.open_keyboard(InputHandler, ws)

          Signal.trap('WINCH') do
            ws.resize
          end
        end
      end

    rescue HaveAPI::Client::ActionFailed => e
      warn "Unable to attach: #{e.message}"
      exit(false)
    end

    protected
    def auth_headers
      auth = @api.communicator.auth

      case auth
      when HaveAPI::Client::Authentication::Basic
        v = Base64.encode64("#{auth.user}:#{auth.password}").strip
        {'Authorization' => "basic #{v}"}

      when HaveAPI::Client::Authentication::Token
        # TODO: this will not work if option `via` is set to `:query_param`
        auth.request_headers

      else
        {}
      end
    end

    def tty(&block)
      if @opts[:tty].nil?
        if $stdout.tty?
          raw_mode(&block)

        else
          block.call
        end

      elsif @opts[:tty] === true
        raw_mode(&block)

      else
        block.call
      end
    end

    def raw_mode
      @state = `stty -g`
      `stty raw -echo -icanon -isig`

      pid = Process.fork { yield }
      Process.wait(pid)

      reset_tty
      puts
    end

    def reset_tty
      `stty #{@state}`
    end
  end
end
