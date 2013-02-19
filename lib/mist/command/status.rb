require 'thor'
require 'mist/interface'

module Mist
  module Command
    class Status < Base
      default_task(:init)
      desc "init", "initialize mist environement"
      def init

        puts "print locally cached status"

      end
    end
  end
end
