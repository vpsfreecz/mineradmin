require 'eventmachine'
require 'websocket-eventmachine-client'
require 'base64'
require 'terminal-size'

module MinerAdmin::CLI::Commands
  class UserProgramAttach < HaveAPI::CLI::Command
    cmd :user_program, :attach
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
      def send_write(data)
        return if data.empty?
        send_cmd('W', Base64.encode64(data))
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

    def options(opts)
      @opts = {}
    end

    def exec(args)
      if args.empty?
        puts "provide user program ID as an argument"
        exit(false)
      end

      raw_mode do
        EventMachine.run do
          ws = WebSocketHandler.connect(
            uri: File.join(
              @api.communicator.url,
              "user-program-io?user_program=#{args[0].strip}"
            ),
            headers: {
              'Authorization' => 'basic YWRtaW46MTIzNA==',
            }
          )

          ws.onopen do
            puts "Connected"
            ws.resize
          end

          ws.onmessage do |msg, type|
            $stdout.write(msg)
            $stdout.flush
          end

          ws.onclose do |code, reason|
            puts "Disconnected with status code: #{code} #{reason}"
            EM.stop
          end

          EventMachine.open_keyboard(InputHandler, ws)

          Signal.trap('WINCH') do
            ws.resize
          end
        end
      end
    end

    protected
    def raw_mode
      state = `stty -g`
      `stty raw -echo -icanon -isig`

      pid = Process.fork do
        yield
      end

      Process.wait(pid)

      `stty #{state}`
      puts
    end
  end
end
