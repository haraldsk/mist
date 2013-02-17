require 'thor'
module Mist
  module Command
    class Destroy < Base
      desc "server", "destroying SERVER"
      def server(server)
        puts "destroying #{server}"
      end
    end
  end
end
