require 'thor'
require 'mist/interface'

module Mist
  module Command
    class Init < Base
      default_task(:init)
      desc "init", "initialize mist environement"
      def init

        puts "1. Setup config files"
        puts "2. generate ssh keys"

      end
    end
  end
end
