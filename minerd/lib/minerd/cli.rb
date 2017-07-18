module Minerd::Cli
  def self.run
    Minerd::State.get
    server = Minerd::Server.new(5000)
    server.run

  rescue Interrupt
    puts 'Got Interrupt..'

  ensure
    server.stop if server
    puts 'Quitting'
  end
end
