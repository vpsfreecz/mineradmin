require 'haveapi/client'

module MinerAdmin
  module Client
    class Client < HaveAPI::Client::Client

    end

    # Shortcut to {MinerAdmin::Client::Client.new}
    def self.new(*args)
      Client.new(*args)
    end
  end
end
