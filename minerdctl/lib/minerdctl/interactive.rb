require 'eventmachine'
require 'base64'

class Minerdctl::Interactive
  class InputHandler < EventMachine::Connection
    attr_accessor :buffer

    def initialize(minerd)
      @minerd = minerd
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
            @minerd.send_detach
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

      @minerd.send_write(@buffer)
      @buffer.clear
    end
  end

  class MinerdHandler < EventMachine::Connection
    def post_init
      @buffer = ''
    end

    def receive_data(data)
      @buffer << data

      loop do
        i = @buffer.index("\n")
        return unless i

        line = @buffer[0..i]
        @buffer = @buffer[i+1..-1]

        cmd, data = line.strip.split(' ')

        case cmd
        when 'W'
          $stdout.write(Base64.strict_decode64(data))
          $stdout.flush

        when 'Q'
          puts "Process exited with status #{data}"
          close_connection_after_writing
        end
      end
    end

    def send_write(data)
      return if data.empty?
      send_cmd('W', Base64.strict_encode64(data))
    end

    def resize(w, h)
      send_cmd('S', w, h)
    end

    def send_detach
      send_cmd('Q')
      close_connection_after_writing
    end

    def unbind
      EM.stop
    end

    protected
    def send_cmd(cmd, *args)
      send_data("#{cmd} #{args.join(' ')}\n")
    end
  end

  def initialize(socket)
    @socket = socket
  end

  def start
    raw_mode do
      EventMachine.run do
        @minerd = EventMachine.attach(@socket, MinerdHandler)
        resize(Terminal.size!)

        Signal.trap('WINCH') do
          resize(Terminal.size!)
        end

        @input = EventMachine.open_keyboard(InputHandler, @minerd)
      end
    end
  end

  protected
  def resize(size)
    @size = size
    @minerd.resize(size[:width], size[:height])
  end

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
