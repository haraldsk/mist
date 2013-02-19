require 'thor'
require 'mist/interface'

module Mist
  module Command
    class Network < Base
      default_task(:init)
      desc "init", "initialize mist environement"
      def init

        puts "add networks from command line"
        puts "remove networks from command line"
        puts "get info on networks"

      end
    end
  end
end
