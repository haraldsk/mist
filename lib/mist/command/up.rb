require 'thor'

module Mist
  module Command
    class Up < Base
      desc "SERVER", "create and start SERVER"
      def up(server)
        puts "Creating and starting #{server}"
      end
    end
  end
end
