require 'thor'
module Mist
  module Command
    class Destroy < Base
      default_task(:destroy)
      desc "destroy", "destroy all servers"
      def destroy
        puts "Destroying all servers."
        interface = Mist::Interface.new()
        interface.destroy()
      end
    end
  end
end
