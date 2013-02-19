require 'thor'
require 'mist/interface'

module Mist
  module Command
    class Up < Base
      default_task(:create)
      desc "create", "create and start all servers"
      def create
        puts "Creating and starting all servers."


        interface = Mist::Interface.new()

        interface.create()

      end
      desc "server SERVER", "create and start all servers"
      def server(machine)
        puts "Creating and starting #{machine}"
      end
    end
  end
end
