require 'thor'
# require 'mist/provisioner/dns'
require 'mist/interface'

module Mist
  module Command
    class Up < Base
      default_task(:up)
      desc "up", "create and start all servers"
      def up
        puts "Creating and starting all servers."

         #provisioner = Mist::Provisioner::Dns.new()
         #provisioner.show_records()

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
