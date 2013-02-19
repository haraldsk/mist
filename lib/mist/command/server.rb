require 'thor'
require 'mist/interface'

module Mist
  module Command
    class Server < Base
      default_task(:init)
      desc "init", "initialize mist environement"
      def init

        puts "add servers from command line"
        puts "destroy servers from command line"
        puts "create images of servers from command line"
        puts "attach and remove storage"
        puts "get info on servers"

      end
    end
  end
end
