require 'haveapi/cli'
require 'mineradmin/client/version'

module MinerAdmin
  module CLI
    module Commands ; end

    class Cli < HaveAPI::CLI::Cli
      def show_version
        puts "#{MinerAdmin::Client::VERSION} based on haveapi-client "+
             HaveAPI::Client::VERSION
      end
    end
  end
end

require 'mineradmin/cli/commands/user_program_attach'
